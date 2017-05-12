class AddDeleteAtVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :deleted_at, :datetime
    add_index :volunteers, :deleted_at
  end
end
