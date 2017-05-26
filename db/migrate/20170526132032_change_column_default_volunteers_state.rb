class ChangeColumnDefaultVolunteersState < ActiveRecord::Migration[5.1]
  def change
    change_column_default :volunteers, :state, from: 'interested/registered', to: 'interested'
  end
end
