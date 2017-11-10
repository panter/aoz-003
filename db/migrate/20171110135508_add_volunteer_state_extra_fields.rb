class AddVolunteerStateExtraFields < ActiveRecord::Migration[5.1]
  def change
    change_table :volunteers do |t|
      t.boolean :active, default: false
    end
  end
end
