class DropIndexOnUsers < ActiveRecord::Migration[5.1]
  def change
    remove_index :users, column: [:email, :active]
    remove_column :users, :active, :boolean
    add_index :users, :email, unique: true
  end
end
