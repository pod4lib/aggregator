class AddUrlToUploads < ActiveRecord::Migration[6.0]
  def change
    add_column :uploads, :url, :string
  end
end
