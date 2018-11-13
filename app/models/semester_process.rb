class SemesterProcess < ApplicationRecord
  belongs_to :creator, -> { with_deleted }, class_name: 'User', inverse_of: 'semester_processes'
  belongs_to :mail_posted_by, -> { with_deleted }, class_name: 'User',
    inverse_of: 'semester_process_mails_posted', optional: true
  belongs_to :reminder_mail_posted_by, -> { with_deleted }, class_name: 'User',
    inverse_of: 'semester_process_reminder_mail_posted', optional: true

  has_many :semester_process_volunteers, dependent: :destroy
  accepts_nested_attributes_for :semester_process_volunteers, allow_destroy: true

  has_many :volunteers, through: :semester_process_volunteers
  has_many :semester_feedbacks, through: :semester_process_volunteers
  has_many :hours, through: :semester_process_volunteers

  has_many :semester_process_volunteer_missions, through: :semester_process_volunteers

  has_many :semester_process_mails, through: :semester_process_volunteers

  def mails
    semester_process_mails.where(kind: 'mail')
  end

  def reminders
    semester_process_mails.where(kind: 'reminder')
  end

  def mail?
    self.mail_subject_template && self.mail_body_template
  end

  def reminder?
    self.reminder_mail_subject_template && self.reminder_mail_body_template
  end

  def kind
    if self.mail?
      return :mail
    elsif self.reminder?
      return :reminder
    end
  end

  def subject
    self.mail_subject_template || self.reminder_mail_subject_template
  end

  def body
    self.mail_body_template || self.reminder_mail_body_template
  end

  # will only return an array, not a AD-result
  delegate :missions, to: :semester_process_volunteers

  # creates semester date range from string '[year],[semester_number]' e.g. '2018,2'
  def semester=(set_semester)
    set_semester = Semester.parse(set_semester) if set_semester.is_a?(String)

    # for very strange reason the end of the range is shifted one day after save
    # possibly a bug in Active Directory
    super(set_semester.begin..set_semester.end.advance(days: -1))
  end

  def semester_t(short: true)
    Semester.i18n_t(semester, short: short)
  end

  def semester_period
    Semester.period(semester)
  end

  def build_semester_volunteers(volunteers, selected = nil)
    volunteers = volunteers.where(id: selected) if selected
    semester_process_volunteers << volunteers.to_a.map do |volunteer|
      spv = SemesterProcessVolunteer.new(volunteer: volunteer, selected: false)
      spv.build_missions(semester)
      spv
    end
  end

  def build_volunteers_hours_feedbacks_and_mails
    semester_process_volunteers.map(&:build_hours_and_mails)
  end
end
