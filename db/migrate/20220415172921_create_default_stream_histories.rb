class CreateDefaultStreamHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :default_stream_histories do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :stream, null: false, foreign_key: true
      t.timestamp :start_time, null:false
      t.timestamp :end_time
    end
  end
end
