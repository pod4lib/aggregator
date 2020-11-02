class DeleteBatches < ActiveRecord::Migration[6.0]
  def change
    table_exists?(:batches) ? drop_table(:batches) : nil
  end
end
