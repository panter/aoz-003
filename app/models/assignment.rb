class Assignment < ApplicationRecord
  include ImportRelation

  belongs_to :client
  accepts_nested_attributes_for :client

  belongs_to :volunteer
  accepts_nested_attributes_for :volunteer

  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  has_many :hours
  has_many :assignment_journals

  STATES = [:suggested, :active, :finished, :archived].freeze

  has_one :import, as: :importable, dependent: :destroy
  accepts_nested_attributes_for :import, allow_destroy: true

  validates :client_id, uniqueness: { scope: :volunteer_id, message: I18n.t('assignment_exists') }
  validates :state, inclusion: { in: STATES.map(&:to_s) }

  scope :default_order, (-> { order(created_at: :desc) })

  scope :no_end, (-> { where(assignment_end: nil) })
  scope :has_end, (-> { where.not(assignment_end: nil) })

  scope :ended, (-> { where('assignment_end < ?', Time.zone.now) })
  scope :end_before, ->(date) { where('assignment_end < ?', date) }
  scope :end_after, ->(date) { where('assignment_end > ?', date) }
  scope :end_within, ->(date_range) { where(assignment_end: date_range) }

  scope :end_in_future, (-> { where('assignment_end > ?', Time.zone.now) })
  scope :not_ended, (-> { no_end.or(end_in_future) })

  scope :started, (-> { where('assignment_start < ?', Time.zone.now) })
  scope :will_start, (-> { where('assignment_start > ?', Time.zone.now) })
  scope :start_before, ->(date) { where('assignment_start < ?', date) }
  scope :start_after, ->(date) { where('assignment_start > ?', date) }
  scope :start_within, ->(date_range) { where(assignment_start: date_range) }

  scope :active, (-> { not_ended.started })

  scope :active_between, lambda { |start_date, end_date|
    start_within(start_date..end_date)
      .or(end_within(start_date..end_date))
      .or(no_end.start_before(start_date))
  }

  scope :zurich, (-> { joins(:client).merge(Client.zurich) })
end
