class AddPreviousStreamIdToStreams < ActiveRecord::Migration[8.0]
  def change
    add_reference :streams, :previous_stream, null: true, foreign_key: false
  end
end
