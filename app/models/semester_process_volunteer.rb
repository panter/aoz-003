class SemesterProcessVolunteer < ApplicationRecord
  belongs_to :volunteer
  belongs_to :semester_process
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
  has_many :mails, -> { mail }, through: :semester_process_mails
  has_many :reminders, -> { reminder }, through: :semester_process_mails

  # will only return an array, not a AD-result
  def missions
    assignments + group_assignments
  end
end
