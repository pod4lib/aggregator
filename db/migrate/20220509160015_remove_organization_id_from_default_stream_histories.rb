class RemoveOrganizationIdFromDefaultStreamHistories < ActiveRecord::Migration[7.0]
  def change
    remove_column :default_stream_histories, :organization_id
  end
end
