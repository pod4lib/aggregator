class PopulateMetadataStatusOnUploads < ActiveRecord::Migration[8.1]
  def up
    Upload.reset_column_information

    Upload.with_attached_files.find_each do |upload|
      upload.send(:update_files_metadata_status)
    end
  end
end
