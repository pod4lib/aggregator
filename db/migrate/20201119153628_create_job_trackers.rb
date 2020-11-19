# frozen_string_literal: true

class CreateJobTrackers < ActiveRecord::Migration[6.0]
  def change
    create_table :job_trackers do |t|
      t.references :reports_on, null: false, polymorphic: true, index: true
      t.references :resource, null: false, polymorphic: true, index: true
      t.string :job_id
      t.string :job_class

      t.timestamps
    end

    add_index :job_trackers, :job_id
  end
end
