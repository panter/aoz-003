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

  # will only return an array, not a AD-result
  delegate :missions, to: :semester_process_volunteers

  # creates semester date range from string '[year],[semester_number]' e.g. '2018,2'
  def semester=(semester)
    if semester.is_a?(String)
      super(Semester.new(*semester.split(',').map(&:to_i)).current)
    else
      super(semester)
    end
  end

end
