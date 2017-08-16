class AddDeletedAtToHours < ActiveRecord::Migration[5.1]
  def change
    add_column :hours, :deleted_at, :datetime
    add_index :hours, :deleted_at
  end
end
