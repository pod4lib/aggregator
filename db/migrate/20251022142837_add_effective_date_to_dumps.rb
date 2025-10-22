class AddEffectiveDateToDumps < ActiveRecord::Migration[8.0]
  def change
    add_column :full_dumps, :effective_date, :datetime
    add_index :full_dumps, :effective_date
    add_column :delta_dumps, :effective_date, :datetime
    add_index :delta_dumps, :effective_date

    reversible do |dir|
      dir.up do
        execute "UPDATE full_dumps SET effective_date = created_at WHERE effective_date IS NULL"
        execute "UPDATE delta_dumps SET effective_date = created_at WHERE effective_date IS NULL"
      end
    end
  end
end
