class AddRelationBetweenSemesterProcessAndHour < ActiveRecord::Migration[5.1]
  def change
    change_table :hours do |t|
      t.references :semester_process_volunteer, foreign_key: true
    end
  end
end
