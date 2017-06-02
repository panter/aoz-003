class ChangeVolunteerStateAndEmail < ActiveRecord::Migration[5.1]
  def change
    change_column_default :volunteers, :state, 'registered'
  end
end
