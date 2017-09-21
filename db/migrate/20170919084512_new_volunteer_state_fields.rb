class NewVolunteerStateFields < ActiveRecord::Migration[5.1]
  def change
    change_table :volunteers do |t|
      t.integer :acceptance, default: 0
      t.datetime :accepted_at
      t.datetime :rejected_at
      t.datetime :resigned_at
      t.datetime :undecided_at
      t.boolean :take_more_assignments, default: false
    end
  end

  def up
    remove_column :volunteers, :state
  end

  def down
    add_column :volunteers, :state, :string, default: 'registered'
  end
end
