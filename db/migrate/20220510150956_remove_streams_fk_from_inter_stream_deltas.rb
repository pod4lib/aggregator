class RemoveStreamsFkFromInterStreamDeltas < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :interstream_deltas, :streams
  end
end
