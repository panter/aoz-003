class PerformanceReport < ApplicationRecord

  before_save :generate_report
  belongs_to :user, -> { with_deleted }

  validates :period_start, presence: true
  validates :period_end, presence: true

  def generate_report
    period_all_year = period_start.all_year
    if period_all_year.end == period_end && period_all_year.begin == period_start
      self.year = period_start.year
    end
    self.report_content = {
      global: global,
      zuerich: zuerich
    }
  end

  def global
    {
      volunteers: volunteers,
      clients: clients,
      assignments: assignments
    }
  end

  def zuerich
    {
      volunteers: volunteers(true),
      clients: clients(true),
      assignments: assignments(true)
    }
  end

  def volunteers(zurich = false)
    volunteers = zurich ? Volunteer.zurich : Volunteer.all
    {
      total: volunteers.count,
      active: volunteers.with_active_assignments_between(period_start, period_end).count,
      new: volunteers.created_between(period_start, period_end).count
    }
  end

  def clients(zurich = false)
    clients = zurich ? Client.zurich : Client.all
    {
      new: clients.created_between(period_start, period_end).count,
      active: clients.with_active_assignment_between(period_start, period_end).count,
      total: clients.count
    }
  end

  def assignments(zurich = false)
    assignments = zurich ? Assignment.zurich : Assignment.all
    {
      ended: assignments.end_within(period_start..period_end).count,
      new: assignments.start_within(period_start..period_end).count,
      active: assignments.active_between(period_start, period_end).count,
      total: assignments.count
    }
  end
end
