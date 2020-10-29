class UpdateJwtAllowlistForOrganizations < ActiveRecord::Migration[6.0]
  def change
    remove_reference :allowlisted_jwts, :user
    change_column :allowlisted_jwts, :exp, :datetime, null: true
    add_reference :allowlisted_jwts, :resource, polymorphic: true
    add_timestamps :allowlisted_jwts, null: true
  end
end
