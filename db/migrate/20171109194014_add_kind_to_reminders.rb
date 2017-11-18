class AddKindToReminders < ActiveRecord::Migration[5.1]
  def change
    add_column :reminders, :kind, :integer
  end
end
