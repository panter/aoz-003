class PerformanceReport < ApplicationRecord
  before_validation :make_report
  belongs_to :user

  def make_report
    report_content = {
      global: {
        volunteers: {
          total: Volunteer.count,
          active: Volunteer.with_active_assignments_between(period_start, period_end).count,
          new: Volunteer.where(created_at: period_start..period_end).count
        },
        assignments: {
          ended: Assignment.end_within(period_start..period_end).count,
          started: Assignment.start_within(period_start..period_end).count,
          total: Assignment.count,
          active: Assignment.active_between(period_start, period_end).count
        }
      },
      zuerich: {
        clients: {
          total: Client.zurich.count,
          active: Assignment.active_between(period_start, period_end).zurich.count
        },
        assignments: {
          ended: Assignment.end_within(period_start..period_end).zurich.count,
          started: Assignment.start_within(period_start..period_end).zurich.count,
          total: Assignment.zurich.count,
          active: Assignment.active_between(period_start, period_end).zurich.count
        }
      }
    }
  end
end
