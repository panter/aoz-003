class Feedback < ApplicationRecord
  include FeedbackTrialFeedbackCommon

  attr_reader :feedbackable_id_and_type

  belongs_to :volunteer
  belongs_to :author, class_name: 'User', inverse_of: 'feedbacks'
  belongs_to :reviewer, class_name: 'User', foreign_key: 'reviewer_id',
    inverse_of: 'reviewed_feedbacks', optional: true
  belongs_to :responsible, class_name: 'User', foreign_key: 'responsible_id',
    inverse_of: 'responsible_feedbacks', optional: true
  belongs_to :feedbackable, polymorphic: true, optional: true

  scope :assignment, (-> { where(feedbackable_type: 'Assignment') })
  scope :group_offer, (-> { where(feedbackable_type: 'GroupOffer') })
  scope :from_assignments, lambda { |assignment_ids|
    assignment.where(feedbackable_id: assignment_ids)
  }
  scope :from_group_offers, lambda { |group_offer_ids|
    group_offer.where(feedbackable_id: group_offer_ids)
  }

  # READ ONLY MODEL
  before_save { false }

  def responsible=(responsible_user)
    self.responsible_at = Time.zone.now
    super(responsible_user)
  end

  def assignment?
    feedbackable_type == 'Assignment'
  end

  def group_offer?
    feedbackable_type == 'GroupOffer'
  end

  def feedbackable_id_and_type=(id_and_type)
    self.feedbackable_id, self.feedbackable_type = id_and_type.split(',', 2)
  end

  def feedbackable_id_and_type
    "#{feedbackable_id},#{feedbackable_type}"
  end
end
