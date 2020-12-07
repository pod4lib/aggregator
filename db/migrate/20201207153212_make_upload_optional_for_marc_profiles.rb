class MakeUploadOptionalForMarcProfiles < ActiveRecord::Migration[6.0]
  def change
    change_column_null(:marc_profiles, :upload_id, true)
  end
end
