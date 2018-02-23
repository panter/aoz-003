class GroupAssignmentLog < ApplicationRecord
  include GroupAssignmentCommon

  belongs_to :group_assignment, -> { with_deleted }, optional: true
end
