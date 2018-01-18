class AssignmentLog < ApplicationRecord
  include AssignmentCommon

  has_one :assignment, -> { with_deleted }, dependent: :nullify

  has_many :hours, as: :hourable, dependent: :destroy
  has_many :feedbacks, as: :feedbackables, dependent: :destroy
  has_many :trial_feedbacks, as: :trial_feedbackable, dependent: :destroy

  scope :created_before, ->(max_time) { where('assignment_logs.created_at < ?', max_time) }
  scope :created_after, ->(min_time) { where('assignment_logs.created_at > ?', min_time) }
end
