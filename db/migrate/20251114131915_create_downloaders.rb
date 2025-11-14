class CreateDownloaders < ActiveRecord::Migration[8.1]
  def change
    create_table :downloaders do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :resource, polymorphic: true, null: false

      t.index [:organization_id, :resource_type, :resource_id], unique: true
      t.timestamps
    end
  end
end
