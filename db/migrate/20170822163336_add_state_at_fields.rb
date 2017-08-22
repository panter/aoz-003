class AddStateAtFields < ActiveRecord::Migration[5.1]
  def change
    change_table :volunteers do |t|
      t.datetime :state_changed_at
    end

    change_table :clients do |t|
      t.datetime :state_changed_at
    end
  end
end
