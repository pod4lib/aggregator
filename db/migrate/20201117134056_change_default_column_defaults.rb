class ChangeDefaultColumnDefaults < ActiveRecord::Migration[6.0]
  def change
    change_column_null(:streams, :default, true)
    change_column_default(:streams, :default, from: nil, to: false)
  end
end
