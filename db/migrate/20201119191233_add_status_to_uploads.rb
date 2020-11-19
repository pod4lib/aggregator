class AddStatusToUploads < ActiveRecord::Migration[6.0]
  def change
    add_column(:uploads, :status, :string, default: 'active')
    add_index(:uploads, :status)
  end
end
