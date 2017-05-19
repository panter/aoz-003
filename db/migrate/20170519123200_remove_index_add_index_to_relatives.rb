class RemoveIndexAddIndexToRelatives < ActiveRecord::Migration[5.1]
  def change
    remove_index :relatives, :relativeable_id
    add_index :relatives, [:relativeable_type, :relativeable_id]
  end
end
