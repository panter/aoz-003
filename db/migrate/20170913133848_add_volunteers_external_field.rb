class AddVolunteersExternalField < ActiveRecord::Migration[5.1]
  def change
    change_table :volunteers do |t|
      t.boolean :external, default: false
    end

    change_table :contacts do |t|
      t.boolean :external, default: false
    end
  end
end
