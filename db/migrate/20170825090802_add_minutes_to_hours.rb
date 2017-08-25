class AddMinutesToHours < ActiveRecord::Migration[5.1]
  def change
    rename_column :hours, :duration, :hours
    add_column :hours, :minutes, :integer
  end
end
