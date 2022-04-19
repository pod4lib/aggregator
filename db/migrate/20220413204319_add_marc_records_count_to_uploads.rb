class AddMarcRecordsCountToUploads < ActiveRecord::Migration[7.0]
  def change
    add_column :uploads, :marc_records_count, :bigint, default: 0
  end
end
