class Hour < ApplicationRecord
  belongs_to :volunteer
  belongs_to :assignment
  belongs_to :billing_expense, optional: true
  belongs_to :certificate, optional: true

  validates :minutes, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validates :hours, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :meeting_date, presence: true

  HOUR_RANGE = (1..8).to_a
  MINUTE_RANGE = [0, 15, 30, 45].freeze
end
