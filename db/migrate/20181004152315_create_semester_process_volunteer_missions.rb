class CreateSemesterProcessVolunteerMissions < ActiveRecord::Migration[5.1]
  def change
    create_table :semester_process_volunteer_missions do |t|
      t.references :semester_process_volunteer, foreign_key: true,
        index: { name: 'semester_proc_volunteer_mission_index' }

      # can be either Assignment or GroupAssignment (not GroupOffer!)
      t.references :assignment, foreign_key: true,
        index: { name: 'semester_proc_volunteer_mission_assignment_index' }
      t.references :group_assignment, foreign_key: true,
        index: { name: 'semester_proc_volunteer_mission_group_assignment_index' }

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
