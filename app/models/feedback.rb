class Feedback < ApplicationRecord
  belongs_to :volunteer
  belongs_to :author, class_name: 'User'
  belongs_to :feedbackable, polymorphic: true, optional: true

  def assignment?
    feedbackable_type == 'Assignment'
  end

  def group_offer?
    feedbackable_type == 'GroupOffer'
  end
end
