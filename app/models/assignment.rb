class Assignment < ApplicationRecord
  include AssignmentCommon
  include VolunteersGroupAndTandemStateUpdate

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
