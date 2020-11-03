class CreateMarcRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :marc_records do |t|
      t.references :file, null: false
      t.references :upload, null: false
      t.string :marc001
      t.bigint :bytecount, null: true
      t.bigint :length, null: true
      t.bigint :index
      t.string :checksum
    end
    add_index :marc_records, [:file_id, :marc001]
    add_index :marc_records, [:upload_id, :marc001]
  end
end
