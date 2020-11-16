class CreateMarcProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :marc_profiles do |t|
      t.references :upload, null: false, foreign_key: true
      t.references :blob, null: false, unique: true
      t.json :field_frequency
      t.json :record_frequency
      t.json :histogram_frequency
      t.json :sampled_values

      t.timestamps
    end
  end
end
