class AddPublicToOrganizations < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :public, :boolean, default: true
  end
end
