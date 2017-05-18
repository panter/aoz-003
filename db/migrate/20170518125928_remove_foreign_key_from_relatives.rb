class RemoveForeignKeyFromRelatives < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :relatives, :clients
  end
end
