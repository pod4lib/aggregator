class CreateStatistics < ActiveRecord::Migration[6.0]
  def change
    create_table :statistics do |t|
      t.references :resource, null: false, index: true, polymorphic: true
      t.bigint :unique_record_count, default: 0
      t.bigint :record_count, default: 0
      t.bigint :file_size, default: 0
      t.bigint :file_count, default: 0
      t.date :date

      t.timestamps
    end

    add_index :statistics, [:resource_type, :resource_id, :date]
  end
end
