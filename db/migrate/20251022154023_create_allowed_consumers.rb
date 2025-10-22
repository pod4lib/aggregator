class CreateAllowedConsumers < ActiveRecord::Migration[8.0]
  def change
    create_table :allowed_consumers do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :allowed_consumer, polymorphic: true, null: false

      t.timestamps
      t.index [:organization_id, :allowed_consumer_type, :allowed_consumer_id], unique: true
    end
  end
end
