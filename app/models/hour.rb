class Hour < ApplicationRecord
  belongs_to :volunteer
  belongs_to :assignment
  belongs_to :billing_expense, optional: true
  belongs_to :certificate, optional: true

  validates :minutes, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :hours, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :meeting_date, presence: true

  scope :billable, (-> { where(billing_expense: nil) })

  HOUR_RANGE = (1..8).to_a
  MINUTE_RANGE = [0, 15, 30, 45].freeze

  def self.total_hours
    sum(&:hours) + sum(&:minutes) / 60
  end

  def self.minutes_rest
    sum(&:minutes) % 60
  end
end
