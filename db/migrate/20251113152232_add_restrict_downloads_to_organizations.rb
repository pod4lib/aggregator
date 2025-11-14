class AddRestrictDownloadsToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :restrict_downloads, :boolean, default: true, null: false

    reversible do |dir|
      dir.up do
        Organization.reset_column_information

        Organization.providers.find_each do |organization|
          organization.update(restrict_downloads: false)
        end
      end
    end
  end
end
