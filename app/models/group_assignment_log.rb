class GroupAssignmentLog < ApplicationRecord
  belongs_to :group_offer
  belongs_to :volunteer
  belongs_to :group_assignment, optional: true
end
