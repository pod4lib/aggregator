class AddRecordAccessToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :record_access, :string, default: 'authenticated_users', null: false
  end
end
