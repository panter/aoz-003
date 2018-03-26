class RemoveMinutes < ActiveRecord::Migration[5.1]
  def change
    remove_column :hours, :minutes
    remove_column :certificates, :minutes
  end
end
