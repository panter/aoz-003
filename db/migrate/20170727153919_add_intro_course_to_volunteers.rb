class AddIntroCourseToVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :intro_course, :boolean, default: false
  end
end
