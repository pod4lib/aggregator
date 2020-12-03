class AddDeleteToMarcRecord < ActiveRecord::Migration[6.0]
  def change
    add_column(:marc_records, :status, :string)
  end
end
