class Feedback < ApplicationRecord
  attr_reader :feedbackable_id_and_type

  belongs_to :volunteer
  belongs_to :author, class_name: 'User'
  belongs_to :feedbackable, polymorphic: true, optional: true

  validates :comments, presence: true

  scope :on_group_offer, lambda { |group_offer_id|
    where(feedbackable_type: 'GroupOffer').where(feedbackable_id: group_offer_id)
  }
  scope :on_assignment, (-> { where(feedbackable_type: 'Assignment') })

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
