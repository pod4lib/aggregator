class CreateInterstreamDeltas < ActiveRecord::Migration[7.0]
  def change
    create_table :interstream_deltas do |t|
      t.references :normalized_dump, null: false, foreign_key: true

      t.timestamps
    end
  end
end
