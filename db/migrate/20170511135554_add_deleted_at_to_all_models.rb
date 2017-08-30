class AddDeletedAtToAllModels < ActiveRecord::Migration[5.1]
  def change
    add_column :schedules, :deleted_at, :datetime
    add_index :schedules, :deleted_at
  end
end
