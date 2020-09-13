# frozen_string_literal: true

class CreateStreams < ActiveRecord::Migration[6.0]
  def change
    create_table(:streams) do |t|
      t.string :name
      t.references :organization
      t.boolean :default

      t.timestamps
    end
  end
end
