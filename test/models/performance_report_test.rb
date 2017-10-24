require 'test_helper'
require 'ostruct'

class GroupOfferCategoryTest < ActiveSupport::TestCase
  def setup
    @today = Time.zone.today
    @year_ago = 1.year.ago.to_date
    @user = create :user
  end

  test 'group offer counts' do
    volunteer = create :volunteer, user: create(:user_volunteer)
    volunteer.update(created_at: 500.days.ago)
    create_group_offer_entity(:this_year, @today.beginning_of_year + 2, nil, volunteer)
    create_group_offer_entity(:last_year, @year_ago, @year_ago.end_of_year - 2, volunteer)
    create_group_offer_entity(:last_year_still, @year_ago, nil, volunteer)

    this_year_rep = extract_results PerformanceReport.create!(user: @user,
      period_start: @today.beginning_of_year, period_end: @today.end_of_year)
    last_year_rep = extract_results PerformanceReport.create!(user: @user,
      period_start: @year_ago.beginning_of_year, period_end: @year_ago.end_of_year)

    assert_equal({ 'active' => 1, 'new' => 0, 'total' => 1 }, this_year_rep.global.volunteers)
    assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0 }, this_year_rep.global.clients)
    assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0 }, this_year_rep.zuerich.volunteers)
    assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0 }, this_year_rep.zuerich.clients)
    assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0, 'ended' => 0 }, this_year_rep.global.assignments)
    assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0, 'ended' => 0 }, this_year_rep.zuerich.assignments)
    assert_equal({ 'active' => 2, 'new' => 1, 'total' => 3, 'ended' => 0 }, this_year_rep.group_offers)

    assert_equal({ 'active' => 1, 'new' => 1, 'total' => 1 }, last_year_rep.global.volunteers)
    assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0 }, last_year_rep.global.clients)
    assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0 }, last_year_rep.zuerich.volunteers)
    assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0 }, last_year_rep.zuerich.clients)
    assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0, 'ended' => 0 }, last_year_rep.global.assignments)
    assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0, 'ended' => 0 }, last_year_rep.zuerich.assignments)
    assert_equal({ 'active' => 2, 'new' => 2, 'total' => 2, 'ended' => 1 }, last_year_rep.group_offers)
  end

  test 'report for this year' do
    main_setup_entities # create basic test set

    this_year = extract_results PerformanceReport.create!(user: @user,
      period_start: @today.beginning_of_year, period_end: @today.end_of_year)
    assert_equal({ 'active' => 4, 'new' => 2, 'total' => 6 },               this_year.global.clients)
    assert_equal({ 'active' => 2, 'new' => 1, 'total' => 3 },               this_year.global.volunteers)
    assert_equal({ 'active' => 2, 'ended' => 0, 'new' => 1, 'total' => 3 }, this_year.global.assignments)
    assert_equal({ 'active' => 2, 'new' => 1, 'total' => 3 },               this_year.zuerich.clients)
    assert_equal({ 'active' => 2, 'new' => 1, 'total' => 3 },               this_year.zuerich.volunteers)
    assert_equal({ 'active' => 2, 'ended' => 0, 'new' => 1, 'total' => 3 }, this_year.zuerich.assignments)
    assert_equal({ 'active' => 2, 'new' => 1, 'total' => 3, 'ended' => 0 }, this_year.group_offers)
  end

  test 'external report for this year' do
    main_setup_entities # create basic test set

    this_year_ext = extract_results PerformanceReport.create!(user: @user, extern: true,
      period_start: @today.beginning_of_year, period_end: @today.end_of_year)
    assert_equal({ 'active' => 4, 'new' => 2, 'total' => 6 },               this_year_ext.global.clients)
    assert_equal({ 'active' => 2, 'new' => 1, 'total' => 3 },               this_year_ext.global.volunteers)
    assert_equal({ 'active' => 2, 'ended' => 0, 'new' => 1, 'total' => 3 }, this_year_ext.global.assignments)
    assert_equal({ 'active' => 2, 'new' => 1, 'total' => 3 },               this_year_ext.zuerich.clients)
    assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0 },               this_year_ext.zuerich.volunteers)
    assert_equal({ 'active' => 0, 'ended' => 0, 'new' => 0, 'total' => 0 }, this_year_ext.zuerich.assignments)
    assert_equal({ 'active' => 2, 'new' => 1, 'total' => 3, 'ended' => 0 }, this_year_ext.group_offers)
  end

  test 'report for last year' do
    main_setup_entities # create basic test set

    last_year_rep = extract_results PerformanceReport.create!(user: @user,
      period_start: @year_ago.beginning_of_year, period_end: @year_ago.end_of_year)
    # more because external volunteers client are counted
    assert_equal({ 'active' => 4, 'new' => 4, 'total' => 4 },               last_year_rep.global.clients)
    assert_equal({ 'active' => 2, 'new' => 2, 'total' => 2 },               last_year_rep.global.volunteers)
    assert_equal({ 'active' => 2, 'ended' => 1, 'new' => 2, 'total' => 2 }, last_year_rep.global.assignments)
    assert_equal({ 'active' => 2, 'new' => 2, 'total' => 2 },               last_year_rep.zuerich.clients)
    assert_equal({ 'active' => 2, 'new' => 2, 'total' => 2 },               last_year_rep.zuerich.volunteers)
    assert_equal({ 'active' => 2, 'ended' => 1, 'new' => 2, 'total' => 2 }, last_year_rep.zuerich.assignments)
    assert_equal({ 'active' => 2, 'new' => 2, 'total' => 2, 'ended' => 1 }, last_year_rep.group_offers)
  end

  test 'external report for last year' do
    main_setup_entities # create basic test set

    last_year_ext = extract_results PerformanceReport.create!(user: @user, extern: true,
      period_start: @year_ago.beginning_of_year, period_end: @year_ago.end_of_year)
    # more because external volunteers client are counted
    assert_equal({ 'active' => 4, 'new' => 4, 'total' => 4 },               last_year_ext.global.clients)
    assert_equal({ 'active' => 2, 'new' => 2, 'total' => 2 },               last_year_ext.global.volunteers)
    assert_equal({ 'active' => 2, 'ended' => 1, 'new' => 2, 'total' => 2 }, last_year_ext.global.assignments)
    assert_equal({ 'active' => 2, 'new' => 2, 'total' => 2 },               last_year_ext.zuerich.clients)
    assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0 },               last_year_ext.zuerich.volunteers)
    assert_equal({ 'active' => 0, 'ended' => 0, 'new' => 0, 'total' => 0 }, last_year_ext.zuerich.assignments)
    assert_equal({ 'active' => 2, 'new' => 2, 'total' => 2, 'ended' => 1 }, last_year_ext.group_offers)
  end

  def main_setup_entities
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
    volunteer = create volunteer, created_at: start_date
    client = create client, user: @user, created_at: start_date
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
