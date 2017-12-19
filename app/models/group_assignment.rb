class GroupAssignment < ApplicationRecord
  include GroupAssignmentAndAssignmentCommon
  include VolunteersGroupAndTandemStateUpdate

  after_update :save_group_assignment_logs, if: :dates_updated?
  before_destroy :save_group_assignment_logs

  belongs_to :group_offer

  has_many :group_assignment_logs
  has_one :group_offer_category, through: :group_offer

  delegate :title, to: :group_offer

  validates :volunteer, uniqueness: {
    scope: :group_offer,
    message: 'Diese/r Freiwillige ist schon im Gruppenangebot'
  }

  scope :active, lambda {
    started.where(
      'group_assignments.period_end > ? OR group_assignments.period_end IS NULL',
      Time.zone.today
    )
  }
  scope :started, lambda {
    where(
      'group_assignments.period_start < ? AND group_assignments.period_start IS NOT NULL',
      Time.zone.today
    )
  }
  scope :ended, lambda {
    where('group_assignments.period_end < ?', Time.zone.today)
  }

  def save_group_assignment_logs
    group_assignment_logs.create!(group_offer_id: group_offer_id, volunteer_id: volunteer_id,
      group_assignment_id: id, title: group_offer.title,
      period_start: period_start_before_last_save, period_end: period_end_before_last_save,
      responsible: responsible)
  end

  def to_label
    label_parts.compact.join(' - ')
  end

  def label_parts
    @label_parts ||= [
      'Gruppenangebot',
      group_offer.title,
      group_offer.department.present? && group_offer.department.contact.last_name
    ]
  end

  def polymorph_url_target
    group_offer
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

  def dates_updated?
    saved_change_to_period_start? || saved_change_to_period_end?
  end
end
