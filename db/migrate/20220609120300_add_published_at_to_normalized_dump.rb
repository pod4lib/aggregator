class AddPublishedAtToNormalizedDump < ActiveRecord::Migration[7.0]
  def change
    add_column :normalized_dumps, :published_at, :timestamp
  end
end
