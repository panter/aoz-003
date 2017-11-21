class AddVolunteerStateExtraFields < ActiveRecord::Migration[5.1]
  def change
    change_table :volunteers do |t|
      t.boolean :active, default: false
      t.date :activeness_might_end
    end
  end

  def up
    remove_column :volunteers, :state
  end

  def down
    add_column :volunteers, :state, :string, default: 'registered'
  end
end
