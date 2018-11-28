class SemesterProcessVolunteer < ApplicationRecord
  attr_accessor :selected

  belongs_to :volunteer
  belongs_to :semester_process
  delegate :semester, to: :semester_process
  delegate :semester_t, to: :semester_process
  delegate :semester_period, to: :semester_process
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

  accepts_nested_attributes_for :group_assignments, :assignments , :semester_process_volunteer_missions , :hours, :volunteer, :semester_feedbacks

  validates_associated :hours, :semester_feedbacks, :volunteer

  scope :index_joins, lambda {
    joins(:semester_process).joins(:semester_process_mails).where("semester_process_mails.kind = 0").joins(volunteer: [:contact]).joins(:semester_process_volunteer_missions)
  }

  scope :index, lambda { |semester = nil|
      joins(:semester_process).where(semester_process: semester)
          .joins(:semester_process_volunteer_missions, volunteer: [:contact])
          .group('semester_process_volunteers.id, contacts_volunteers.last_name')
  }


  def semester_feedback_with_mission(mission)
    self.semester_feedbacks.order(:created_at).select{|sf| sf.mission == mission}.last
  end

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

  def build_hours_and_mails
    missions.each do |mission|
      hours << mission.hours.date_between_inclusion(:meeting_date, semester.begin, semester.end)
    end
    semester_process_mails << SemesterProcessMail.new(kind: semester_process.kind, sent_by: creator,
                                subject: semester_process.subject,
                                body:    semester_process.body)
  end

  def render_feedback(field)
    field_size = 0
    semester_feedbacks.each do |f|
      field_size += f[field].size
    end
    semester_feedbacks.map(&field).compact.join('<hr>').html_safe if field_size != 0
  end

  def responsible=(responsible_user)
    self.responsibility_taken_at = Time.zone.now
    super(responsible_user)
  end
end
