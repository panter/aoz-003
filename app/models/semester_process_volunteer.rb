class SemesterProcessVolunteer < ApplicationRecord
  attr_accessor :selected

  belongs_to :volunteer
  belongs_to :semester_process, optional: true
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

  has_many :semester_process_mails, dependent: :destroy
  has_many :mails, -> { where(kind: 'mail') }, class_name: 'SemesterProcessMail',
    foreign_key: 'semester_process_volunteer_id', inverse_of: 'semester_process_volunteer'
  has_many :reminders, -> { where(kind: 'reminder') }, class_name: 'SemesterProcessMail',
    foreign_key: 'semester_process_volunteer_id', inverse_of: 'semester_process_volunteer'

  accepts_nested_attributes_for :group_assignments, :assignments, :semester_process_volunteer_missions, :volunteer, :semester_feedbacks

  validates_associated :hours, :semester_feedbacks, :volunteer

  scope :without_reminders, lambda { |semester|
    joins(:semester_process).where(semester_process: semester).joins(:semester_process_mails).where("semester_process_mails.kind = 0")
  }

  scope :active_missions, lambda {
    joins(:semester_process_volunteer_missions).includes(semester_process_volunteer_missions: [:assignment, :group_assignment])
    .where("(semester_process_volunteer_missions.assignment_id IS NOT NULL AND
            assignments.period_end IS NULL)
            OR
           (semester_process_volunteer_missions.group_assignment_id IS NOT NULL AND
           group_assignments.period_end is NULL)")
    .references(:assignments, :group_assignments)
  }

  scope :index_scope, lambda { |semester = nil|
    active_missions.without_reminders(semester)
  }

  scope :without_feedback, lambda {
    left_outer_joins(:semester_feedbacks).where(semester_feedbacks: { id: nil})
  }

  scope :unsubmitted, -> { where(commited_at: nil) }
  scope :submitted, -> { where.not(commited_at: nil) }

  scope :in_semester, lambda { |semester|
    semester = (Date.parse(semester)..Date.parse(semester).advance(months: 5).end_of_month) if semester.is_a?(String)
    joins(:semester_process).where('semester_processes.semester && daterange(?,?)', semester.begin, semester.end)
  }

  def hours
    missions.map do |m|
      m.hours.within_semester(semester)
    end.flatten
  end

  def semester_feedback_with_mission(mission)
    semester_feedbacks.order(:created_at).select { |sf| sf.mission == mission }.last
  end

  # will only return an array, not a AD-result
  def missions
    semester_process_volunteer_missions.map(&:mission)
  end

  def build_missions(semester)
    # if you change this then also change it within active_semester_mission(semester)
    prob = semester.end.advance(weeks: -4)
    new_missions = volunteer.assignments.no_end.start_before(prob) +
      volunteer.group_assignments.no_end.start_before(prob)

    semester_process_volunteer_missions << new_missions.map do |mission|
      SemesterProcessVolunteerMission.new(mission: mission)
    end
  end

  def build_mails(kind = :mail)
    semester_process.kind = kind
    semester_process_mails << SemesterProcessMail.new(kind: kind, sent_by: creator,
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

  def render_feedback_conversation
    semester_feedbacks.map(&:conversation).any?
  end

  def responsible=(responsible_user)
    self.responsibility_taken_at = Time.zone.now
    super(responsible_user)
  end
end
