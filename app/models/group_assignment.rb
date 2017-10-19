class GroupAssignment < ApplicationRecord
  belongs_to :group_offer
  belongs_to :volunteer
  has_many :group_assignment_logs

  after_update :save_group_assignment_logs, if: :dates_updated?
  before_destroy :save_group_assignment_logs

  scope :started, (-> { where('period_start < ?', Time.zone.today) })
  scope :ongoing, (-> { where('group_assignments.period_end > ?', Time.zone.today) })
  scope :no_end, (-> { where(period_end: nil) })

  scope :start_within, ->(date_range) { where(period_start: date_range) }
  scope :end_within, ->(date_range) { where(period_end: date_range) }
  scope :start_before, ->(date) { where('period_start < ?', date) }

  scope :active_between, lambda { |start_date, end_date|
    start_within(start_date..end_date)
      .or(end_within(start_date..end_date))
  }

  def save_group_assignment_logs
    group_assignment_logs.create!(group_offer_id: group_offer_id, volunteer_id: volunteer_id,
      group_assignment_id: id, title: group_offer.title,
      period_start: period_start_before_last_save, period_end: period_end_before_last_save,
      responsible: responsible)
  end

  private

  def dates_updated?
    saved_change_to_period_start? || saved_change_to_period_end?
  end
end
