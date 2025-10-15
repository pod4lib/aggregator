class AddMarc001IndexToMarcRecords < ActiveRecord::Migration[8.0]
  def change
    add_index :marc_records, [:marc001, :upload_id]
  end
end
