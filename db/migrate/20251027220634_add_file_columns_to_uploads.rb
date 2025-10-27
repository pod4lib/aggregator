class AddFileColumnsToUploads < ActiveRecord::Migration[8.1]
  def change
    add_column :uploads, :deletes_count, :integer, default: 0
    add_column :uploads, :metadata_status, :string
    add_column :uploads, :total_byte_size, :integer, default: 0

    reversible do |dir|
      dir.up do
        Upload.reset_column_information

        Upload.includes(files_attachments: :blob).find_each do |upload|
          total_byte_size = upload.files_attachments.sum { |file| file.blob.byte_size }
          deletes_count = upload.files_attachments.sum { |file| file.blob.metadata['type'] == 'deletes' ? file.blob.metadata['count'] : 0 }

          upload.update(total_byte_size: total_byte_size, marc_records_count: upload.marc_records_count - deletes_count, deletes_count: deletes_count)
        end
      end
    end
  end
end
