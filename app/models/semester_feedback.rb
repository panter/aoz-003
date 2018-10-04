class SemesterFeedback < ApplicationRecord
  belongs_to :author, -> { with_deleted }, class_name: 'User', inverse_of: 'semester_feedbacks'
  belongs_to :semester_process_volunteer
  has_one :semester_process, through: :semester_process_volunteer
  has_one :volunteer, through: :semester_process_volunteer

  # relates to either Assignment or GroupAssignment (not GroupOffer!)
  belongs_to :assignment, optional: true
  belongs_to :group_assignment, optional: true

  validate :validate_group_assignment_or_assignment_present

  def mission
    group_assignment || assignment
  end

  private

  def validate_group_assignment_or_assignment_present
    errors.add(:association_insuficient) if assignment.blank? && group_assignment.blank?
  end
end
