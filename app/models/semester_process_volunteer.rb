class SemesterProcessVolunteer < ApplicationRecord
  attr_accessor :selected

  belongs_to :volunteer
  belongs_to :semester_process
  delegate :semester, to: :semester_process
  delegate :creator, to: :semester_process

  belongs_to :responsible, -> { with_deleted }, class_name: 'User',
    inverse_of: 'semester_processes', optional: true
  belongs_to :reviewed_by, -> { with_deleted }, class_name: 'User',
    inverse_of: 'semester_processes', optional: true
  belongs_to :commited_by, -> { with_deleted }, class_name: 'User',
    inverse_of: 'semester_processes', optional: true

  has_many :semester_process_volunteer_missions, dependent: :destroy
  has_many :assignments, through: :semester_process_volunteer_missions
  has_many :group_assignments, through: :semester_process_volunteer_missions

  has_many :semester_feedbacks, dependent: :destroy
  has_many :hours, dependent: :nullify

  has_many :semester_process_mails, dependent: :destroy
  has_many :mails, -> { where(kind: 'mail') }, class_name: 'SemesterProcessMail',
    foreign_key: 'semester_process_volunteer_id', inverse_of: 'semester_process_volunteer'
  has_many :reminders, -> { where(kind: 'reminder') }, class_name: 'SemesterProcessMail',
    foreign_key: 'semester_process_volunteer_id', inverse_of: 'semester_process_volunteer'

  # will only return an array, not a AD-result
  def missions
    semester_process_volunteer_missions.map(&:mission)
  end

  def build_missions(semester)
    new_missions = volunteer.assignments.active_between(semester.begin, semester.end) +
      volunteer.group_assignments.active_between(semester.begin, semester.end)

    semester_process_volunteer_missions << new_missions.map do |mission|
      SemesterProcessVolunteerMission.new(mission: mission)
    end
  end

  def build_hours_feedbacks_and_mails
    missions.each do |mission|
      hours << mission.hours.date_between_inclusion(:meeting_date, semester.begin, semester.end)
      semester_feedbacks << SemesterFeedback.new(mission: mission, volunteer: mission.volunteer)
    end
    semester_process_mails << SemesterProcessMail.new(kind: :mail, sent_by: creator)
  end
end
