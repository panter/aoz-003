class Hour < ApplicationRecord
  include NotMarkedDone

  attr_reader :hourable_id_and_type

  belongs_to :volunteer

  belongs_to :hourable, polymorphic: true, optional: true

  belongs_to :billing_expense, optional: true
  belongs_to :certificate, optional: true
  belongs_to :marked_done_by, class_name: 'User', optional: true

  validates :minutes, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :hours, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :meeting_date, presence: true

  scope :billable, (-> { where(billing_expense: nil) })

  scope :since_last_submitted, lambda { |submitted_at|
    where('created_at > ?', submitted_at) if submitted_at
  }

  HOUR_RANGE = (1..8).to_a
  MINUTE_RANGE = [0, 15, 30, 45].freeze

  def assignment?
    hourable_type == 'Assignment'
  end

  def group_offer?
    hourable_type == 'GroupOffer'
  end

  def self.total_hours
    sum(&:hours) + sum(&:minutes) / 60
  end

  def self.minutes_rest
    sum(&:minutes) % 60
  end

  def hourable_id_and_type=(id_and_type)
    self.hourable_id, self.hourable_type = id_and_type.split(',', 2)
  end

  def hourable_id_and_type
    "#{hourable_id},#{hourable_type}"
  end
end
