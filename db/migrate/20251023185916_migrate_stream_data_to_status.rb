class MigrateStreamDataToStatus < ActiveRecord::Migration[8.0]
  def up
    Stream.where(default: true).update_all(status: 'default')
    Stream.where(id: DefaultStreamHistory.where.not(end_time: nil).joins(:stream).where('stream.status': 'active').pluck(:stream_id)).update_all(status: 'previous-default')
  end

  def down
    Stream.where(status: 'default').update_all(default: true)
  end
end
