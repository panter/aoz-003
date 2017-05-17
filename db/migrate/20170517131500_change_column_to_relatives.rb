class ChangeColumnToRelatives < ActiveRecord::Migration[5.1]
  def change
    rename_column :relatives, :client_id, :relativeable_id
    add_column :relatives, :relativeable_type, :string
  end
end
