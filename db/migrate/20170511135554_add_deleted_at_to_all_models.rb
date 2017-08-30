class AddDeletedAtToAllModels < ActiveRecord::Migration[5.1]
  def change

    add_column :relatives, :deleted_at, :datetime
    add_index :relatives, :deleted_at

    add_column :schedules, :deleted_at, :datetime
    add_index :schedules, :deleted_at
  end
end
