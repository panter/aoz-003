class ChangeEventKindDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_null(:events, :kind, from: true)
  end
end
