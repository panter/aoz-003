class AddMissingDeletedAtColumns < ActiveRecord::Migration[5.1]
  def change
    add_column :departments, :deleted_at, :datetime
    add_index :departments, :deleted_at

    add_column :contacts, :deleted_at, :datetime
    add_index :contacts, :deleted_at

    add_column :contact_points, :deleted_at, :datetime
    add_index :contact_points, :deleted_at
  end
end
