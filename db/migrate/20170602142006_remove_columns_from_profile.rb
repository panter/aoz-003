class RemoveColumnsFromProfile < ActiveRecord::Migration[5.1]
  def change
    remove_column :profiles, :first_name, :string
    remove_column :profiles, :last_name, :string
    remove_column :profiles, :phone, :string
    remove_column :profiles, :address, :text
  end
end
