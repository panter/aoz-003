class GroupAssignmentLog < ApplicationRecord
  belongs_to :group_offer
  belongs_to :volunteer
  belongs_to :group_assignment, optional: true
  has_many :reminder_mailing_volunteers, as: :reminder_mailable, dependent: :destroy
end
