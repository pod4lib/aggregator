class RemoveInterstreamDeltas < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :interstream_deltas, :normalized_dumps
    drop_table :interstream_deltas
  end
end
