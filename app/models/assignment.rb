class Assignment < ApplicationRecord
  include ImportRelation
  include GroupAssignmentAndAssignmentScopes

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

  has_one :import, as: :importable, dependent: :destroy
  accepts_nested_attributes_for :import, allow_destroy: true

  validates :client_id, uniqueness: { scope: :volunteer_id, message: I18n.t('assignment_exists') }

  scope :created_before, ->(max_time) { where('assignments.created_at < ?', max_time) }
  scope :created_after, ->(min_time) { where('assignments.created_at > ?', min_time) }

  scope :ended, (-> { where('assignments.period_end < ?', Time.zone.today) })

  def started_six_months_ago?
    period_start < 6.months.ago.to_date
  end

  def started_ca_six_weeks_ago?
    period_start < 6.weeks.ago && period_start > 8.weeks.ago
  end

  scope :zurich, (-> { joins(:client).merge(Client.zurich) })
  scope :not_zurich, (-> { joins(:client).merge(Client.not_zurich) })

  scope :internal, (-> { joins(:volunteer).merge(Volunteer.internal) })
  scope :external, (-> { joins(:volunteer).merge(Volunteer.external) })

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
    label = I18n.t('activerecord.models.assignment')
    label += " - #{client.contact.full_name}" if client.contact.present?
    label += " - #{period_start && I18n.l(period_start)}"
    label
  end
end
