class RemoveSpvFromHours < ActiveRecord::Migration[5.1]
  def change
    remove_column :hours, :semester_process_volunteer_id
  end
end
