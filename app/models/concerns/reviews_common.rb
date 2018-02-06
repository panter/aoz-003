module ReviewsCommon
  extend ActiveSupport::Concern

  included do
    scope :need_review, -> { where(reviewer_id: nil) }
  end
end
