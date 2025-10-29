class AddFieldsToJobTracker < ActiveRecord::Migration[8.1]
  def change
    add_column :job_trackers, :status, :string
    add_column :job_trackers, :data, :text
  end
end
