class Assignment < ApplicationRecord
  include ImportRelation
  include GroupAssignmentAndAssignmentCommon
  include VolunteersGroupAndTandemStateUpdate

  after_update :delete_reminder, if: :saved_change_to_confirmation?

  belongs_to :client
  accepts_nested_attributes_for :client

  belongs_to :creator, -> { with_deleted }, class_name: 'User'
  has_many :hours, as: :hourable, dependent: :destroy

  has_many :feedbacks, as: :feedbackable, dependent: :destroy
  has_many :trial_feedbacks, as: :trial_feedbackable, dependent: :destroy
  has_many :reminders, dependent: :destroy

  STATES = [:suggested, :active, :finished, :archived].freeze

  has_one :import, as: :importable, dependent: :destroy
  accepts_nested_attributes_for :import, allow_destroy: true

  validates :client_id, uniqueness: { scope: :volunteer_id, message: I18n.t('assignment_exists') }

  scope :created_before, ->(max_time) { where('assignments.created_at < ?', max_time) }
  scope :created_after, ->(min_time) { where('assignments.created_at > ?', min_time) }

  scope :active, lambda {
    started.where(
      'assignments.period_end > ? OR assignments.period_end IS NULL',
      Time.zone.today
    )
  }
  scope :started, lambda {
    where(
      'assignments.period_start < ? AND assignments.period_start IS NOT NULL',
      Time.zone.today
    )
  }
  scope :ended, lambda {
    where('assignments.period_end < ?', Time.zone.today)
  }

  scope :zurich, (-> { joins(:client).merge(Client.zurich) })
  scope :not_zurich, (-> { joins(:client).merge(Client.not_zurich) })

  def creator
    super || User.deleted.find_by(id: creator_id)
  end

  def last_feedback
    feedbacks.where(author: volunteer.user).last
  end

  def last_trial_feedback
    trial_feedbacks.last
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
