class AddFullDumpIdToNormalizedDumps < ActiveRecord::Migration[6.0]
  def change
    add_reference :normalized_dumps, :full_dump, foreign_key: false, null: true
  end
end
