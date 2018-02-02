class PerformanceReport < ApplicationRecord
  before_save :generate_report
  belongs_to :user, -> { with_deleted }

  validates :period_start, presence: true
  validates :period_end, presence: true

  def periods
    @periods ||= [period_start.to_time.midnight, period_end.to_time.end_of_day]
  end

  def generate_report
    period_all_year = period_start.all_year
    if period_all_year.end == period_end && period_all_year.begin == period_start
      self.year = period_start.year
    end
    binding.pry
    self.report_content = {
      volunteers: volunteer_performance,
      # clients: client_performance,
      # assignments: assignment_performance
    }
  end

  def volunteer_performance
    volunteers = Volunteer.created_before(periods.last)
    {
      all: volunteers_stats(volunteers),
      zurich: volunteers_stats(volunteers.zurich),
      not_zurich: volunteers_stats(volunteers.not_zurich),
      external: volunteers_stats(volunteers.external),
      internal: volunteers_stats(volunteers.internal)
    }
  end

  def volunteers_stats(volunteers)
    assignment_active = volunteers.with_active_assignments_between(*periods).distinct.ids
    group_active = volunteers.with_active_group_assignments_between(*periods).distinct.ids
    active_both = assignment_active & group_active
    {
      total: volunteers.count,
      active_assignment: assignment_active.size,
      active_group_assignment: group_active.size,
      active_both: active_both.size,
      created: volunteers.created_after(periods.first).count,
      # resigned: volunteers.resigned_between(*periods).count,
      inactive: volunteers.where.not(id: assignment_active + group_active).distinct.count
    }
  end

  def client_performance
    clients = Client.created_before(periods.last)
    {
      all: clients_stats(clients),
      zurich: clients_stats(clients),
      not_zurich: clients_stats(clients)
    }
  end

  def clients_stats(clients)
    {
      created: clients.created_after(periods.first).count,
      active_assignment: clients.active.count,
      inactive: clients.inactive.count,
      total: clients.count,
      resigned: clients.resigned_between(*periods).count
    }
  end

  def assignment_performance
    assignments = Assignment.created_before(periods.last)
    {
      all: assignments_stats(assignments),
      zurich: assignments_stats(assignments.zurich),
      not_zurich: assignments_stats(assignments.not_zurich),
      external: assignments_stats(assignments.external),
      internal: assignments_stats(assignments.internal)
    }
  end

  def assignments_stats(assignments)
    hours = Hour.date_between(:meeting_date, *periods).from_assignments(assignments.ids)
    feedbacks = Feedback.created_between(*periods).from_assignments(assignments.ids)
    {
      created: assignments.created_between(*periods).count,
      started: assignments.start_within(*periods).count,
      active: assignments.active_between(*periods).count,
      probations_ended: assignments.date_between(:probation_period, *periods).count,
      performance_appraisal_reviews: assignments.date_between(:performance_appraisal_review, *periods).count,
      home_visits: assignments.date_between(:home_visit, *periods).count,
      first_instruction_lessons: assignments.date_between(:first_instruction_lesson, *periods).count,
      progress_meetings: assignments.date_between(:progress_meeting, *periods).count,
      ended: assignments.end_within(*periods).count,
      termination_submitted: assignments.termination_submitted_between(*periods).count,
      termination_verified: assignments.termination_verified_between(*periods).count,
      all: assignments.count,
      hour_report_count: hours.count,
      hours: hours.sum(:hours) + (hours.sum(:minutes) / 60),
      feedback_count: feedbacks.count
    }
  end

  def group_offer_performance
    group_offers = GroupOffer.created_before(periods.last)
    group_assignments = GroupAssignment.where(group_offer_id: group_offers.ids)
    active_ga = group_assignments.active_between(*periods)
    started_ga = group_assignments.start_within(*periods)
    ended_ga = group_assignments.end_within(*periods)
    # created_ga = group_assignments.created_between(*periods)
    hours = Hour.from_group_offers(group_offers.ids)
    feedbacks = Feedback.created_between(*periods).from_group_offers(group_offers.ids)
    {
      all: group_offers.count,
      created: group_offers.created_after(periods.first).count,
      ended: group_offers.end_within(*periods).count,
      termination_verified: group_offers.termination_verified_between(*periods).count,
      # created_assignments: created_ga.pluck(:group_offer_id).uniq.size,
      started_assignments: started_ga.pluck(:group_offer_id).uniq.size,
      active_assignments: active_ga.pluck(:group_offer_id).uniq.size,
      ended_assignments: ended_ga.pluck(:group_offer_id).uniq.size,
      hour_report_count: hours.count,
      hours: hours.sum(:hours) + (hours.sum(:minutes) / 60),
      feedback_count: feedbacks.count,
      in_departments: group_offers.where.not(department_id: nil).count
    }
  end
end
