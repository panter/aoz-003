class RemoveForeignKeyFromSchedules < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :schedules, :clients
  end
end
