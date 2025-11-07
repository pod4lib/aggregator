class RemovePublicFlagFromOrganizations < ActiveRecord::Migration[8.1]
  def change
    remove_column :organizations, :public, :boolean, default: false, null: false
  end
end
