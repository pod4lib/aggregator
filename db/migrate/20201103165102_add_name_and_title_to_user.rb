class AddNameAndTitleToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :name, :string
    add_column :users, :title, :string
  end
end
