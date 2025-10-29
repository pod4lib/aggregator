class ChangeUploadColumnsToBigints < ActiveRecord::Migration[8.1]
  def up
    change_column :uploads, :total_byte_size, :bigint, default: 0
    change_column :uploads, :deletes_count, :bigint, default: 0
  end
end
