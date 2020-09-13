class AddSlugToStreams < ActiveRecord::Migration[6.0]
  def change
    add_column :streams, :slug, :string
    add_index :streams, :slug, unique: true
  end
end
