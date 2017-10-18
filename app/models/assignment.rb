class Assignment < ApplicationRecord
  include ImportRelation

  after_update :delete_reminder, if: :saved_change_to_confirmation?

  belongs_to :client
  accepts_nested_attributes_for :client

  belongs_to :volunteer
  accepts_nested_attributes_for :volunteer

  belongs_to :creator, -> { with_deleted }, class_name: 'User'
  has_many :hours, as: :hourable, dependent: :destroy

  has_many :feedbacks, as: :feedbackable, dependent: :destroy
  has_many :reminders, dependent: :destroy

  STATES = [:suggested, :active, :finished, :archived].freeze
  KINDS = [:accompaniment, :family, :workshop, :german_class, :transit_center].freeze

  has_one :import, as: :importable, dependent: :destroy
  accepts_nested_attributes_for :import, allow_destroy: true

  validates :client_id, uniqueness: { scope: :volunteer_id, message: I18n.t('assignment_exists') }

  scope :default_order, (-> { order(created_at: :desc) })

  scope :created_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }
  scope :created_before, ->(max_time) { where('assignments.created_at < ?', max_time) }
  scope :created_after, ->(min_time) { where('assignments.created_at > ?', min_time) }

  scope :no_end, (-> { where(period_end: nil) })
  scope :has_end, (-> { where.not(period_end: nil) })

  scope :ended, (-> { where('assignments.period_end < ?', Time.zone.today) })
  scope :end_before, ->(date) { where('period_end < ?', date) }
  scope :end_after, ->(date) { where('period_end > ?', date) }
  scope :end_within, ->(date_range) { where(period_end: date_range) }

  scope :end_in_future, (-> { where('period_end > ?', Time.zone.today) })
  scope :not_ended, (-> { no_end.or(end_in_future) })

  scope :started, (-> { where('period_start < ?', Time.zone.today) })
  scope :will_start, (-> { where('period_start > ?', Time.zone.today) })
  scope :start_before, ->(date) { where('period_start < ?', date) }
  scope :start_after, ->(date) { where('period_start > ?', date) }
  scope :start_within, ->(date_range) { where(period_start: date_range) }

  scope :started_six_months_ago, (-> { where('period_start < ?', 6.months.ago.to_date) })

  def started_six_months_ago?
    period_start < 6.months.ago.to_date
  end

  scope :active, (-> { not_ended.started })
  scope :inactive, (-> { ended })

  scope :active_between, lambda { |start_date, end_date|
    start_within(start_date..end_date)
      .or(end_within(start_date..end_date))
      .or(no_end.start_before(start_date))
  }

  scope :zurich, (-> { joins(:client).merge(Client.zurich) })

  scope :with_hours, (-> { joins(:hours) })

  def ended?
    period_end && period_end < Time.zone.today
  end

  def ongoing?
    !ended?
  end

  def inactive?
    ended? || period_start > Time.zone.today
  end

  def active?
    ongoing? && period_start < Time.zone.today
  end

  def creator
    super || User.deleted.find_by(id: creator_id)
  end

  def last_feedback
    feedbacks.where(author: volunteer.user).last
  end

  def last_hour
    hours.last
  end

  def delete_reminder
    Reminder.where(assignment: id).destroy_all
  end

  def to_label
    label = "#{self.class.name.humanize}"
    label += " - #{client.contact.full_name}" if client.contact.present?
    label += " - #{period_start && I18n.l(period_start)}"
    label
  end
end
