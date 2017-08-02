class DropContactPoints < ActiveRecord::Migration[5.1]
  def change
    drop_table :contact_points
  end
end
