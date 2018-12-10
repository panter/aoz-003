class SemesterProcessVolunteerMission < ApplicationRecord
  include MissionEitherOneRelation

  delegate :volunteer, to: :semester_process_volunteer
  belongs_to :semester_process_volunteer

  scope :active_missions, lambda {
    joins(semester_process_volunteer: [:semester_process]).includes(:assignment, :group_assignment)
    .where("semester_process_volunteer_missions.assignment_id IS NOT NULL AND 
           (assignments.period_end IS NULL OR assignments.period_end >= lower(semester_processes.semester)) 
            OR 
            semester_process_volunteer_missions.group_assignment_id IS NOT NULL AND 
           (group_assignments.period_end is NULL OR group_assignments.period_end >= lower(semester_processes.semester))")
    .references(:assignments, :group_assignments)
  }
end
