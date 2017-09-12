class AddDefaultZeroToHours < ActiveRecord::Migration[5.1]
  def up
    change_column_default :hours, :hours, 0
    change_column_default :hours, :minutes, 0
  end

  def down
    change_column_default :hours, :hours, nil
    change_column_default :hours, :minutes, nil
  end
end
