class CreateFullDumps < ActiveRecord::Migration[8.0]
  def change
    create_table :full_dumps do |t|
      t.references :stream, null: false, foreign_key: false
      t.references :normalized_dump, null: false, foreign_key: true
      t.datetime :published_at

      t.timestamps
    end
    add_index :full_dumps, :published_at


    reversible do |dir|
      dir.up do
        say_with_time 'Backfilling full dumps for existing normalized dumps' do
          FullDump.reset_column_information

          NormalizedDump.where(full_dump_id: nil).find_each do |normalized_dump|
            FullDump.create!(
              stream_id: normalized_dump.stream_id,
              normalized_dump_id: normalized_dump.id,
              published_at: normalized_dump.published_at,
              created_at: normalized_dump.created_at,
              updated_at: normalized_dump.updated_at
            )
          end
        end
      end
    end
  end
end
