class AddCompactedUploadIdToUploads < ActiveRecord::Migration[8.0]
  def change
    add_reference :uploads, :compacted_upload, index: true
  end
end
