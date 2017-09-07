class Reminder < ApplicationRecord
  belongs_to :assignment
  belongs_to :volunteer

  default_scope { order(created_at: :desc) }
end
