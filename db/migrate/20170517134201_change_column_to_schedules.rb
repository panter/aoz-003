class ChangeColumnToSchedules < ActiveRecord::Migration[5.1]
  def change
    rename_column :schedules, :client_id, :scheduleable_id
    add_column :schedules, :scheduleable_type, :string
  end
end
