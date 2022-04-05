class AddProviderToOrganizations < ActiveRecord::Migration[7.0]
  def change
    add_column :organizations, :provider, :boolean, default: true
  end
end
