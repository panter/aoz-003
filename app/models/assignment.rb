class Assignment < ApplicationRecord
  include ImportRelation
  include GroupAssignmentAndAssignmentCommon
  include VolunteersGroupAndTandemStateUpdate

  belongs_to :client
  accepts_nested_attributes_for :client

  belongs_to :creator, -> { with_deleted }, class_name: 'User'

  # termination record relations
  belongs_to :period_end_set_by, -> { with_deleted }, class_name: 'User', optional: true
  belongs_to :termination_submitted_by, -> { with_deleted }, class_name: 'User', optional: true
  belongs_to :termination_verified_by, -> { with_deleted }, class_name: 'User', optional: true

  has_many :hours, as: :hourable, dependent: :destroy
  has_many :feedbacks, as: :feedbackable, dependent: :destroy

  has_many :trial_feedbacks, as: :trial_feedbackable, dependent: :destroy

  has_one :import, as: :importable, dependent: :destroy
  accepts_nested_attributes_for :import, allow_destroy: true

  validates :client_id, uniqueness: { scope: :volunteer_id, message: I18n.t('assignment_exists') }

  scope :created_before, ->(max_time) { where('assignments.created_at < ?', max_time) }
  scope :created_after, ->(min_time) { where('assignments.created_at > ?', min_time) }

  scope :zurich, (-> { joins(:client).merge(Client.zurich) })
  scope :not_zurich, (-> { joins(:client).merge(Client.not_zurich) })

  scope :termination_not_submitted, (-> { ended.where(termination_submitted_by_id: nil) })
  scope :termination_submitted, (-> { ended.where.not(termination_submitted_by_id: nil) })
  scope :termination_not_verified, (-> { ended.where(termination_verified_by_id: nil) })
  scope :termination_verified, (-> { ended.where.not(termination_verified_by_id: nil) })

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

  def polymorph_url_object
    self
  end

  def to_label
    label_parts.compact.join(' - ')
  end

  def label_parts
    @label_parts ||= [
      I18n.t('activerecord.models.assignment'),
      client.contact.full_name,
      period_start && I18n.l(period_start)
    ]
  end

  def polymorph_url_target
    self
  end

  def hours_since_last_submitted
    hours.since_last_submitted(submitted_at)
  end

  def feedbacks_since_last_submitted
    feedbacks.since_last_submitted(submitted_at)
  end

  def assignment?
    true
  end

  def group_assignment?
    false
  end
end
