class GroupAssignment < ApplicationRecord
  include VolunteersGroupAndTandemStateUpdate
  include GroupAssignmentCommon

  after_save :update_group_offer_search_field

  has_many :group_assignment_logs

  has_many :hours, ->(object) { where(volunteer: object.volunteer) }, through: :group_offer
  has_many :feedbacks, ->(object) { where(volunteer: object.volunteer) }, through: :group_offer

  delegate :title, to: :group_offer

  validates :volunteer, uniqueness: {
    scope: :group_offer,
    message: 'Diese/r Freiwillige ist schon im Gruppenangebot'
  }

  scope :running, (-> { no_end.have_start })

  def termination_verifiable?
    ended? && termination_submitted_by.present?
  end

  def verify_termination(user)
    update(termination_verified_by: user, termination_verified_at: Time.zone.now)
    create_log_of_self
  end

  def create_log_of_self(start_date = period_start, end_date = period_end)
    GroupAssignmentLog.create(
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

  def update_group_offer_search_field
    group_offer.update_search_volunteers
  end
end
