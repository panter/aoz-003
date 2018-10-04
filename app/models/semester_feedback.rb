class SemesterFeedback < ApplicationRecord
  belongs_to :author, -> { with_deleted }, class_name: 'User', inverse_of: 'semester_feedbacks'
  belongs_to :semester_process_volunteer
  has_one :semester_process, through: :semester_process_volunteer
  has_one :volunteer, through: :semester_process_volunteer

  # relates to either Assignment or GroupAssignment (not GroupOffer!)
  belongs_to :semester_feedbackable, polymorphic: true, optional: true
end
