class AddStreamToInterstreamDeltas < ActiveRecord::Migration[7.0]
  def change
    add_reference :interstream_deltas, :stream, null: false, foreign_key: true
  end
end
