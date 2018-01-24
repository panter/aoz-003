class GroupAssignment < ApplicationRecord
  include VolunteersGroupAndTandemStateUpdate
  include GroupAssignmentCommon

  after_save :update_group_offer_search_field
  after_update :save_group_assignment_logs, if: :dates_updated?
  before_destroy :create_log_of_self_and_delete_self

  has_many :group_assignment_logs

  delegate :title, to: :group_offer

  validates :volunteer, uniqueness: {
    scope: :group_offer,
    message: 'Diese/r Freiwillige ist schon im Gruppenangebot'
  }

  def save_group_assignment_logs
    create_log_of_self(period_start_before_last_save, period_end_before_last_save)
  end

  def create_log_of_self(start_date = period_start, end_date = period_end)
    GroupAssignmentLog.create!(
      attributes.except('id', 'created_at', 'updated_at', 'active')
        .merge(title: group_offer.title, group_assignment_id: id, period_start: start_date,
               period_end: end_date)
    )
  end

  def hours_since_last_submitted
    group_offer.hours.since_last_submitted(submitted_at)
  end

  def feedbacks_since_last_submitted
    group_offer.feedbacks.since_last_submitted(submitted_at)
  end

  def polymorph_url_object
    group_offer
  end

  def assignment?
    false
  end

  def group_assignment?
    true
  end

  private

  def create_log_of_self_and_delete_self
    delete if create_log_of_self && !running?
  end

  def dates_updated?
    saved_change_to_period_start? || saved_change_to_period_end?
  end

  def update_group_offer_search_field
    group_offer.update_search_volunteers
  end
end
