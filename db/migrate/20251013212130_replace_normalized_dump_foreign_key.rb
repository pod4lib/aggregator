class ReplaceNormalizedDumpForeignKey < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :normalized_dumps, :streams
  end
end
