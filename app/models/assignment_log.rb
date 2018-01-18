class AssignmentLog < ApplicationRecord
  include AssignmentCommon

  scope :created_before, ->(max_time) { where('assignment_logs.created_at < ?', max_time) }
  scope :created_after, ->(min_time) { where('assignment_logs.created_at > ?', min_time) }
end
