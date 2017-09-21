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
    volunteers = Volunteer.created_before(period_end)
    volunteers = extern ? volunteers.external : volunteers.internal
    volunteers = volunteers.zurich if zurich
    {
      total: volunteers.count,
      active: volunteers.with_active_assignments_between(period_start, period_end).distinct.count,
      new: volunteers.created_between(period_start, period_end).count
    }
  end

  def clients(zurich = false)
    clients = Client.created_before(period_end)
    clients = clients.zurich if zurich
    {
      new: clients.created_between(period_start, period_end).distinct.count,
      active: clients.with_active_assignment_between(period_start, period_end).distinct.count,
      total: clients.count
    }
  end

  def assignments(zurich = false)
    assignments = Assignment.created_before(period_end)
    assignments = assignments.zurich if zurich
    {
      ended: assignments.end_within(period_start..period_end).count,
      new: assignments.start_within(period_start..period_end).count,
      active: assignments.active_between(period_start, period_end).count,
      total: assignments.count
    }
  end
end
