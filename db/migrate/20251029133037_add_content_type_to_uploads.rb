class AddContentTypeToUploads < ActiveRecord::Migration[8.1]
  def change
    add_column :uploads, :content_type, :string

    reversible do |dir|
      dir.up do
        Upload.reset_column_information

        Upload.includes(files_attachments: :blob).find_each do |upload|
          content_type = upload.files_attachments.map { |file| file.blob.content_type }.compact.uniq.join(', ')
          upload.update(content_type: content_type)
        end
      end
    end
  end
end
