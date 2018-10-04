class SemesterProcess < ApplicationRecord
  belongs_to :creator, -> { with_deleted }, class_name: 'User', inverse_of: 'semester_processes'
  belongs_to :mail_posted_by, -> { with_deleted }, class_name: 'User',
    inverse_of: 'semester_process_mails_posted', optional: true
  belongs_to :semester_process_reminder_mail_posted, -> { with_deleted }, class_name: 'User',
    inverse_of: 'semester_process_mails_posted', optional: true

  has_many :semester_process_volunteers, dependent: :destroy
  has_many :volunteers, through: :semester_process_volunteers
  has_many :semester_feedbacks, through: :semester_process_volunteers
  has_many :semester_process_mails, through: :semester_process_volunteers
  has_many :mails, -> { mail }, through: :semester_process_mails
  has_many :reminders, -> { reminder }, through: :semester_process_mails
end
