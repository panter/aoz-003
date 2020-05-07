class AssignmentLog < ApplicationRecord
  include AssignmentCommon

  belongs_to :assignment, -> { with_deleted }

  has_many :hours, as: :hourable, dependent: :destroy
  has_many :feedbacks, as: :feedbackables, dependent: :destroy

  def restore_assignment
    assignment.restore && delete
    assignment
  end
end
