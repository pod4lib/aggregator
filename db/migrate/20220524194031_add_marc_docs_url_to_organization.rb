class AddMarcDocsUrlToOrganization < ActiveRecord::Migration[7.0]
  def change
    add_column :organizations, :marc_docs_url, :string, null: true
  end
end
