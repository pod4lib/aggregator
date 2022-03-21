class AddAddProviderJobIdToJobTracker < ActiveRecord::Migration[7.0]
  def change
    add_column :job_trackers, :provider_job_id, :string
    add_index :job_trackers, :provider_job_id
  end
end
