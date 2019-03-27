class SemesterProcessVolunteerMission < ApplicationRecord
  include MissionEitherOneRelation

  belongs_to :semester_process_volunteer
  delegate :volunteer, to: :semester_process_volunteer
  has_one :semester_process, through: :semester_process_volunteer
  delegate :semester, to: :semester_process

  scope :need_feedback, lambda {
    includes(:assignment, :group_assignment, semester_process_volunteer: [:semester_process])
      .references(:assignments, :group_assignments, semester_process_volunteer: [:semester_process])
      .where(<<-SQL.squish)
      (semester_process_volunteer_missions.assignment_id IS NOT NULL AND
        (assignments.period_end IS NULL
          OR
        assignments.period_end > lower(semester_processes.semester))
      ) OR (semester_process_volunteer_missions.group_assignment_id IS NOT NULL AND
        (group_assignments.period_end IS NULL
          OR
        group_assignments.period_end > lower(semester_processes.semester))
      )
    SQL
  }
end
