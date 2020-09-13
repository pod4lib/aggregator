# frozen_string_literal: true

class CreateBatches < ActiveRecord::Migration[6.0]
  def change
    create_table(:batches) do |t|
      t.references :stream
      t.bigint :order

      t.timestamps
    end
  end
end
