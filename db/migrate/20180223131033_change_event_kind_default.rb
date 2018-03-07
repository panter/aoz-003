class ChangeEventKindDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:events, :kind, nil)
  end
end
