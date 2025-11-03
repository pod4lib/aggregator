class AddUniqueIndexForJobTrackerJobId < ActiveRecord::Migration[8.1]
  def change
    remove_index :job_trackers, :job_id, if_exists: true
    add_index :job_trackers, :job_id, unique: true
  end
end
