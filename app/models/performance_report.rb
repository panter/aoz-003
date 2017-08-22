class PerformanceReport < ApplicationRecord
  before_validation :make_report
  belongs_to :user

  def make_report
    binding.pry
    {
      volunteer: {
        total: Volunteer.count,
        active_assignments: Volunteer.with_active_assignments_between(period_start, period_end).count
      },
      assignments: {
        ended: Assignment.end_within(period_start..period_end).count,
        started: Assignment.start_within(period_start..period_end).count,
        total: Assignment.count,
        active: Assignment.active_between(period_start, period_end).count
      }
    }
  end
end
