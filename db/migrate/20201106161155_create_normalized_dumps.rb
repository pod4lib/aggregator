class CreateNormalizedDumps < ActiveRecord::Migration[6.0]
  def change
    create_table :normalized_dumps do |t|
      t.references :stream, null: false, foreign_key: true
      t.timestamp :last_full_dump_at
      t.timestamp :last_delta_dump_at

      t.timestamps
    end
  end
end
