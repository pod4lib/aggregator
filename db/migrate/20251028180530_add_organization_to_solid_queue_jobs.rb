class AddOrganizationToSolidQueueJobs < ActiveRecord::Migration[8.1]
  def change
    add_column :solid_queue_jobs, :organization_id, :string
    add_index :solid_queue_jobs, :organization_id
  end
end
