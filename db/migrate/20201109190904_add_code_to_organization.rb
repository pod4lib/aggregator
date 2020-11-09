class AddCodeToOrganization < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :code, :string
  end
end
