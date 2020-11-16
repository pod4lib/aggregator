class AddNormalizationStepsToOrganizations < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :normalization_steps, :json
  end
end
