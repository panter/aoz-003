class ChangeHourToFloat < ActiveRecord::Migration[5.1]
  def change
    change_column :hours, :hours, :float
  end
end
