class AddJsonToMarcRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :marc_records, :json, :blob
  end
end
