class AddStatusToStreams < ActiveRecord::Migration[6.0]
  def change
    add_column(:streams, :status, :string, default: 'active')
    add_index(:streams, :status)
  end
end
