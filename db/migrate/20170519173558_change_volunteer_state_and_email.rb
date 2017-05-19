class ChangeVolunteerStateAndEmail < ActiveRecord::Migration[5.1]
  def change
    change_column_default :volunteers, :state, 'registered'
    add_column :volunteers, :active, :boolean
    add_index :volunteers, :email, unique: true, where: 'active'
  end
end
