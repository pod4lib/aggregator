class CreateGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :groups do |t|
      t.string :name
      t.string :short_name
      t.string :slug
      t.text :description

      t.timestamps
    end
    add_index :groups, :slug, unique: true
  end
end
