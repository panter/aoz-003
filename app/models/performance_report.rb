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
      zuerich: zuerich,
      group_offers: group_offers
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
    volunteers = zurich ? volunteers.zurich : volunteers.not_zurich
    active_ids = volunteers.with_active_assignments_between(period_start, period_end).ids
    active_ids += volunteers.with_active_group_assignments_between(period_start, period_end).ids
    {
      total: volunteers.count,
      active: active_ids.uniq.size,
      new: volunteers.created_between(period_start, period_end).size
    }
  end

  def clients(zurich = false)
    clients = Client.created_before(period_end)
    clients = zurich ? clients.zurich : clients.not_zurich
    {
      new: clients.created_between(period_start, period_end).distinct.count,
      active: clients.with_active_assignment_between(period_start, period_end).distinct.count,
      total: clients.count
    }
  end

  def assignments(zurich = false)
    assignments = Assignment.created_before(period_end)
    assignments = zurich ? assignments.zurich : assignments.not_zurich
    assignments = extern ? assignments.external : assignments.internal
    {
      ended: assignments.end_within(period_start..period_end).count,
      new: assignments.start_within(period_start..period_end).count,
      active: assignments.active_between(period_start, period_end).count,
      total: assignments.count
    }
  end

  def group_offers
    group_offers = GroupOffer.created_before(period_end)
    active = group_offers.map do |group_offer|
      group_offer.active_group_assignments_between?(period_start, period_end)
    end.grep(true)
    ended = group_offers.map do |group_offer|
      group_offer.all_group_assignments_ended_within?(period_start..period_end)
    end.grep(true)
    new_group_offers = group_offers.map do |group_offer|
      group_offer.all_group_assignments_started_within?(period_start..period_end)
    end.grep(true)
    {
      active: active.size,
      new: new_group_offers.size,
      total: group_offers.count,
      ended: ended.size
    }
  end
end
