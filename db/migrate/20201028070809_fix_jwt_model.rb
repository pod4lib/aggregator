class FixJwtModel < ActiveRecord::Migration[6.0]
  def change
    rename_column :allowlisted_jwts, :users_id, :user_id
    change_column :allowlisted_jwts, :aud, :string, null: true
  end
end
