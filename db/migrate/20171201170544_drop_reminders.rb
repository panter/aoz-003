class DropReminders < ActiveRecord::Migration[5.1]
  def change
    drop_table :reminders
  end
end
