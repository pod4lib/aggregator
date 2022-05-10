class RemoveOrganizationsFkFromDefaultStreamHistories < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :default_stream_histories, :organizations
  end
end
