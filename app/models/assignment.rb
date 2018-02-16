class Assignment < ApplicationRecord
  include AssignmentCommon
  include VolunteersGroupAndTandemStateUpdate

  has_many :hours, as: :hourable
  has_many :feedbacks, as: :feedbackable
  has_many :trial_feedbacks, as: :trial_feedbackable
  has_one :assignment_log

  validates :client_id, uniqueness: {
    scope: :volunteer_id, message: I18n.t('assignment_exists')
  }

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

  def verify_termination(user)
    update(termination_verified_by: user, termination_verified_at: Time.zone.now)
    create_log_of_self
  end

  def create_log_of_self
    AssignmentLog.create(
      attributes.except('id', 'created_at', 'updated_at').merge(assignment_id: id)
    )
  end

  # allow ransack to use defined scopes
  def self.ransackable_scopes(auth_object = nil)
    ['active', 'inactive', 'active_or_not_yet_active']
  end
end
