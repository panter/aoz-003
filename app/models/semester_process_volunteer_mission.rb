class SemesterProcessVolunteerMission < ApplicationRecord
  include MissionEitherOneRelation

  delegate :volunteer, to: :semester_process_volunteer
  belongs_to :semester_process_volunteer

  scope :need_feedback, lambda {
    includes(:assignment, :group_assignment)
    .where("(semester_process_volunteer_missions.assignment_id IS NOT NULL AND 
           assignments.period_end IS NULL)
            OR 
           (semester_process_volunteer_missions.group_assignment_id IS NOT NULL AND 
           group_assignments.period_end is NULL)")
    .references(:assignments, :group_assignments)
  }
end
