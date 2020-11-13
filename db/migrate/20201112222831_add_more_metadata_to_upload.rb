class AddMoreMetadataToUpload < ActiveRecord::Migration[6.0]
  def change
    add_column :uploads, :user_id, :integer
    add_column :uploads, :allowlisted_jwts_id, :integer
    add_column :uploads, :ip_address, :string
  end
end
