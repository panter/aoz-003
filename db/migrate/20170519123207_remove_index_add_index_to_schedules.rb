class RemoveIndexAddIndexToSchedules < ActiveRecord::Migration[5.1]
  def change
    remove_index :schedules, :scheduleable_id
    add_index :schedules, [:scheduleable_type, :scheduleable_id]
  end
end
