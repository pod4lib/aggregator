class AddLabelToAllowlistedJwts < ActiveRecord::Migration[6.0]
  def change
    add_column :allowlisted_jwts, :label, :string
    add_column :allowlisted_jwts, :scope, :string, default: 'all'
  end
end
