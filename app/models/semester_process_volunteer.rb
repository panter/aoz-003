class SemesterProcessVolunteer < ApplicationRecord
  belongs_to :volunteer
  belongs_to :semester_process
  belongs_to :responsible, -> { with_deleted }, class_name: 'User',
    inverse_of: 'semester_processes', optional: true
  belongs_to :reviewed_by, -> { with_deleted }, class_name: 'User',
    inverse_of: 'semester_processes', optional: true
  belongs_to :commited_by, -> { with_deleted }, class_name: 'User',
    inverse_of: 'semester_processes', optional: true

  has_many :semester_feedbacks, dependent: :destroy
end
