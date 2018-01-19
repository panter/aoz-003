class Assignment < ApplicationRecord
  include AssignmentCommon
  include VolunteersGroupAndTandemStateUpdate

  before_destroy :create_log_of_self_and_delete_self

  has_many :hours, as: :hourable
  has_many :feedbacks, as: :feedbackable
  has_many :trial_feedbacks, as: :trial_feedbackable
  has_one :assignment_log

  validates :client_id, uniqueness: { scope: :volunteer_id, message: I18n.t('assignment_exists') }

  scope :created_before, ->(max_time) { where('assignments.created_at < ?', max_time) }
  scope :created_after, ->(min_time) { where('assignments.created_at > ?', min_time) }

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

  def hours_since_last_submitted
    hours.since_last_submitted(submitted_at)
  end

  def feedbacks_since_last_submitted
    feedbacks.since_last_submitted(submitted_at)
  end

  def terminated?
    termination_verifiable? && termination_verified_by.present?
  end

  def termination_verifiable?
    ended? && termination_submitted_by.present?
  end

  def verify_termination(user)
    update(termination_verified_by: user, termination_verified_at: Time.zone.now)
    create_log_of_self
  end

  def create_log_of_self
    return false if running? # prevent deleteing of running assignment
    log = AssignmentLog.new(attributes.except('id', 'created_at', 'updated_at'))
    log.assignment = self
    log.save
  end

  private

  def create_log_of_self_and_delete_self
    create_log_of_self
    delete
  end
end
