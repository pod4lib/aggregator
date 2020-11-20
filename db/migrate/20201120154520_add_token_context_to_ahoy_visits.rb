class AddTokenContextToAhoyVisits < ActiveRecord::Migration[6.0]
  def change
    add_column :ahoy_visits, :token_id, :string
    add_index :ahoy_visits, :token_id
    add_column :ahoy_visits, :organization_id, :string
    add_index :ahoy_visits, :organization_id
  end
end
