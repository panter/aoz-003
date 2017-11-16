require 'ostruct'
require 'test_helper'

module PerformanceReportGenerator
  def main_setup_entities
    @today ||= Time.zone.today
    @year_ago ||= Time.zone.today.years_ago 1
    # Assignments beginning this year with no period_end
    create_assignment_entity(:this_year_z, :volunteer_z, :client_z, @today.beginning_of_year + 2)
    create_assignment_entity(:this_year_g, :volunteer, :client, @today.beginning_of_year + 2)
    create_assignment_entity(:this_year_e, :volunteer_external, :client, @today.beginning_of_year + 2)
    # Group offer beginning this year, using volunteers active and created this year
    create_group_offer_entity(:this_year, @today.beginning_of_year + 2, nil, @v_this_year_z, @v_this_year_g)

    # Assginments beginning last year with no period_end (still active)
    create_assignment_entity(:last_year_still_z, :volunteer_z, :client_z, @year_ago)
    create_assignment_entity(:last_year_still_g, :volunteer, :client, @year_ago)
    create_assignment_entity(:last_year_still_e, :volunteer_external, :client, @year_ago)
    # Group offer beginning last_year, using volunteers active and created this year
    create_group_offer_entity(:last_year_still,  @year_ago, nil, @v_last_year_still_z, @v_last_year_still_g)

    # Assignments beginning last year and period_end last year (ended and inactive now)
    create_assignment_entity(:last_year_z, :volunteer_z, :client_z, @year_ago, @year_ago.end_of_year - 2)
    create_assignment_entity(:last_year_g, :volunteer, :client, @year_ago, @year_ago.end_of_year - 2)
    create_assignment_entity(:last_year_e, :volunteer_external, :client, @year_ago, @year_ago.end_of_year - 2)
    create_group_offer_entity(:last_year,  @year_ago, @year_ago.end_of_year - 2, @v_last_year_z, @v_last_year_g)
  end

  def extract_results(report)
    accessible = OpenStruct.new(report.report_content)
    accessible.global = OpenStruct.new(accessible.global)
    accessible.zuerich = OpenStruct.new(accessible.zuerich)
    accessible
  end

  def create_assignment_entity(title, volunteer, client, start_date, end_date = nil)
    volunteer = create volunteer
    volunteer.update(created_at: start_date)
    client = create client, user: @user
    client.update(created_at: start_date)
    assignment = create_assignment(title && "a_#{title}", volunteer, client, start_date, end_date)
    assignment.update(created_at: start_date)
    return [volunteer, client, assignment] unless title
    instance_variable_set("@c_#{title}", client)
    instance_variable_set("@v_#{title}", volunteer)
  end

  def create_group_offer_entity(title, start_date, end_date, *volunteers)
    category = create :group_offer_category, category_name: "Category #{title}"
    group_offer = create_group_offer(title, category, volunteers.size, start_date)
    group_offer.update(created_at: start_date)
    group_assignments = volunteers.map do |volunteer|
      g_assignment = GroupAssignment.new(group_offer: group_offer, volunteer: volunteer,
        period_start: start_date, period_end: end_date)
      g_assignment.save
      g_assignment
    end
    return [group_offer, category, group_assignments] unless title
    instance_variable_set("@category_#{title}", category)
    instance_variable_set("@group_ass_#{title}", group_assignments)
    [group_offer, category, group_assignments]
  end

  def create_assignment(title, volunteer, client, period_start = nil, period_end = nil)
    period_start ||= @today.beginning_of_year
    assignment = create :assignment, volunteer: volunteer, client: client, creator: @user,
      period_start: period_start, period_end: period_end, created_at: period_start
    assignment.update(created_at: period_start)
    return assignment unless title
    instance_variable_set("@#{title}", assignment)
  end

  def create_group_offer(title, group_offer_category, volunteer_count, start_date)
    group_offer = create :group_offer, group_offer_category: group_offer_category, title: title,
      necessary_volunteers: volunteer_count
    group_offer.update(created_at: start_date)
    return group_offer unless title
    instance_variable_set("@group_offer_#{title}", group_offer)
    group_offer
  end
end
