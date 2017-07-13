class RenameUserIdToCreatorIdOnAssignments < ActiveRecord::Migration[5.1]
  def change
    rename_column :assignments, :user_id, :creator_id
  end
end
