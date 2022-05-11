class RemoveStreamIdFromInterstreamDeltas < ActiveRecord::Migration[7.0]
  def change
    remove_column :interstream_deltas, :stream_id
  end
end
