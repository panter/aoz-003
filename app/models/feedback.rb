class Feedback < ApplicationRecord
  attr_reader :feedbackable_id_and_type

  belongs_to :volunteer
  belongs_to :author, class_name: 'User'
  belongs_to :feedbackable, polymorphic: true, optional: true
  belongs_to :marked_done_by, class_name: 'User', optional: true

  validates :comments, presence: true

  scope :author_volunteer, (-> { joins(:volunteer).where('author_id = volunteers.user_id') })

  scope :since_last_submitted, lambda { |submitted_at|
    if submitted_at
      author_volunteer.where('feedbacks.created_at > ?', submitted_at)
    else
      author_volunteer
    end
  }

  scope :not_marked_done, (-> { where('marked_done_by_id IS NULL') })

  def assignment?
    feedbackable_type == 'Assignment'
  end

  def group_offer?
    feedbackable_type == 'GroupOffer'
  end

  def feedbackable_link_target
    return feedbackable if assignment?
    feedbackable.group_offer
  end

  def feedbackable_id_and_type=(id_and_type)
    self.feedbackable_id, self.feedbackable_type = id_and_type.split(',', 2)
  end

  def feedbackable_id_and_type
    "#{feedbackable_id},#{feedbackable_type}"
  end
end
