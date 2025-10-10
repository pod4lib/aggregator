class UpdateStreamSlugUniq < ActiveRecord::Migration[8.0]
  def change
    add_index :streams, [:organization_id, :slug], unique: true, if_not_exists: true
    remove_index :streams, :slug, unique: true, if_exists: true
  end
end
