class ChangeOrganizationRecordAccessDefault < ActiveRecord::Migration[8.1]
  def change
    change_column_default(:organizations, :record_access, from: 'authenticated_users', to: 'managed')
  end
end
