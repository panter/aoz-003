module ReviewsCommon
  extend ActiveSupport::Concern

  included do
    belongs_to :reviewer, class_name: 'User', optional: true
    scope :need_review, -> { where(reviewer_id: nil) }
  end
end
