# frozen_string_literal: true

class CreateDeviseJwtAllowlist < ActiveRecord::Migration[6.0]
  def change
    create_table :allowlisted_jwts do |t|
      t.string :jti, null: false
      t.string :aud, null: false
      t.datetime :exp, null: false
      t.references :users, foreign_key: { on_delete: :cascade }, null: false
    end

    add_index :allowlisted_jwts, :jti, unique: true
  end
end
