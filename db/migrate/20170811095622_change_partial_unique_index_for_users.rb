class ChangePartialUniqueIndexForUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :active, :boolean
    remove_index :users, :email
    add_index :users, [:email, :active], unique: true
  end
end
