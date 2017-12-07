module NotMarkedDone
  extend ActiveSupport::Concern

  included do
    scope :not_marked_done, (-> { where('marked_done_by_id IS NULL') })
  end
end
