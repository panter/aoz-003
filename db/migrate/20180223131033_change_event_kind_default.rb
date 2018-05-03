class ChangeEventKindDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:events, :kind, from: false, to: nil)
    change_column_null(:events, :kind, true)
  end
end
