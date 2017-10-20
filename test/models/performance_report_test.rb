require 'test_helper'

class GroupOfferCategoryTest < ActiveSupport::TestCase
  def setup
    @today = Time.zone.today
    @year_ago = 1.year.ago.to_date
    @user = create :user
  end

  test 'only group offer entitys exist' do
    volunteer = create :volunteer, user: create(:user_volunteer)
    volunteer.update(created_at: 500.days.ago)
    this_year_go = create_group_offer_entity(:this_year, @today.beginning_of_year + 2, nil,
      volunteer)
    last_year_gro, _rest = create_group_offer_entity(:last_year, @year_ago, @year_ago.end_of_year - 2,
      volunteer)
    last_year_still_active_gro, _rest = create_group_offer_entity(:last_year_still, @year_ago, nil,
      volunteer)

    last_year_gro.update(created_at: @year_ago.beginning_of_year + 2)
    last_year_still_active_gro.update(created_at: @year_ago.beginning_of_year + 2)

    report_this_year = PerformanceReport.create!(period_start: @today.beginning_of_year,
      period_end: @today.end_of_year, user: @user)
    report_last_year = PerformanceReport.create!(period_start: @year_ago.beginning_of_year,
      period_end: @year_ago.end_of_year, user: @user)

    gl_vol, gl_cli, gl_ass, z_vol, z_cli, z_ass, group_off = extract_results(report_this_year)
    binding.pry
    # assert_equal({ 'active' => 1, 'new' => 0, 'total' => 1 }, gl_vol)
    # assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0 }, gl_cli)
    # assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0 }, z_vol)
    # assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0 }, z_cli)
    # assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0, 'ended' => 0 }, gl_ass)
    # assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0, 'ended' => 0 }, z_ass)
    # assert_equal({ 'active' => 2, 'new' => 1, 'total' => 3, 'ended' => 0 }, group_off)

    gl_vol, gl_cli, gl_ass, z_vol, z_cli, z_ass, group_off = extract_results(report_last_year)
    binding.pry
    # assert_equal({ 'active' => 1, 'new' => 1, 'total' => 1 }, gl_vol)
    # assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0 }, gl_cli)
    # assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0 }, z_vol)
    # assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0 }, z_cli)
    # assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0, 'ended' => 0 }, gl_ass)
    # assert_equal({ 'active' => 0, 'new' => 0, 'total' => 0, 'ended' => 0 }, z_ass)
    # assert_equal({ 'active' => 2, 'new' => 2, 'total' => 2, 'ended' => 1 }, group_off)
  end

  # test 'this year report' do
  #   main_setup_entities
  #   report_this_year = PerformanceReport.create!(period_start: @today.beginning_of_year,
  #     period_end: @today.end_of_year, user: @user)
  #   gl_vol, gl_cli, gl_ass, z_vol, z_cli, z_ass, group_off = extract_results(report_this_year)

  #   assert_equal 1, z_vol['active']
  #   assert_equal 1, z_vol['new']
  #   assert_equal 3, z_vol['total']

  #   assert_equal 1, z_cli['active']
  #   assert_equal 1, z_cli['new']
  #   assert_equal 3, z_cli['total']

  #   assert_equal 1, z_ass['active']
  #   assert_equal 1, z_ass['new']
  #   assert_equal 3, z_ass['total']
  #   assert_equal 0, z_ass['ended']

  #   assert_equal 2, gl_vol['active']
  #   assert_equal 2, gl_vol['new']
  #   assert_equal 6, gl_vol['total']

  #   assert_equal 3, gl_cli['active']
  #   assert_equal 3, gl_cli['new']
  #   assert_equal 9, gl_cli['total']

  #   assert_equal 3, gl_ass['active']
  #   assert_equal 3, gl_ass['new']
  #   assert_equal 9, gl_ass['total']
  #   assert_equal 0, gl_ass['ended']

  #   assert_equal 1, group_off['active']
  #   assert_equal 3, group_off['new']
  #   assert_equal 3, group_off['total']
  #   assert_equal 3, group_off['ended']
  # end

  # test 'last year report' do
  #   main_setup_entities
  #   report_last_year = PerformanceReport.create!(period_start: @year_ago.beginning_of_year,
  #     period_end: @year_ago.end_of_year, user: @user)
  #   gl_vol, gl_cli, gl_ass, z_vol, z_cli, z_ass, group_off = extract_results(report_last_year)

  #   assert_equal 2, z_vol['active']
  #   assert_equal 2, z_vol['new']
  #   assert_equal 2, z_vol['total']

  #   assert_equal 2, z_cli['active']
  #   assert_equal 2, z_cli['new']
  #   assert_equal 2, z_cli['total']

  #   assert_equal 2, z_ass['active']
  #   assert_equal 2, z_ass['new']
  #   assert_equal 2, z_ass['total']
  #   assert_equal 1, z_ass['ended']

  #   assert_equal 4, gl_vol['active']
  #   assert_equal 4, gl_vol['new']
  #   assert_equal 4, gl_vol['total']

  #   assert_equal 6, gl_cli['active']
  #   assert_equal 6, gl_cli['new']
  #   assert_equal 6, gl_cli['total']

  #   assert_equal 6, gl_ass['active']
  #   assert_equal 6, gl_ass['new']
  #   assert_equal 6, gl_ass['total']
  #   assert_equal 3, gl_ass['ended']

  #   assert_equal 2, group_off['active']
  #   assert_equal 2, group_off['new']
  #   assert_equal 2, group_off['total']
  #   assert_equal 2, group_off['ended']
  # end

  # test 'this year extern report' do
  #   main_setup_entities
  #   report_this_year_extern = PerformanceReport.create!(period_start: @today.beginning_of_year,
  #     period_end: @today.end_of_year, user: @user, extern: true)
  #   gl_vol, gl_cli, gl_ass, z_vol, z_cli, z_ass, group_off = extract_results(report_this_year_extern)

  #   assert_equal 0, z_vol['active']
  #   assert_equal 0, z_vol['new']
  #   assert_equal 0, z_vol['total']

  #   assert_equal 1, z_cli['active']
  #   assert_equal 1, z_cli['new']
  #   assert_equal 3, z_cli['total']

  #   assert_equal 1, z_ass['active']
  #   assert_equal 1, z_ass['new']
  #   assert_equal 3, z_ass['total']
  #   assert_equal 0, z_ass['ended']

  #   assert_equal 1, gl_vol['active']
  #   assert_equal 1, gl_vol['new']
  #   assert_equal 3, gl_vol['total']

  #   assert_equal 3, gl_cli['active']
  #   assert_equal 3, gl_cli['new']
  #   assert_equal 9, gl_cli['total']

  #   assert_equal 3, gl_ass['active']
  #   assert_equal 3, gl_ass['new']
  #   assert_equal 9, gl_ass['total']
  #   assert_equal 0, gl_ass['ended']

  #   assert_equal 1, group_off['active']
  #   assert_equal 3, group_off['new']
  #   assert_equal 3, group_off['total']
  #   assert_equal 3, group_off['ended']
  # end

  # test 'last year extern report' do
  #   main_setup_entities
  #   report_last_year_extern = PerformanceReport.create!(period_start: @year_ago.beginning_of_year,
  #     period_end: @year_ago.end_of_year, user: @user, extern: true)
  #   gl_vol, gl_cli, gl_ass, z_vol, z_cli, z_ass, group_off = extract_results(report_last_year_extern)

  #   assert_equal 0, z_vol['active']
  #   assert_equal 0, z_vol['new']
  #   assert_equal 0, z_vol['total']

  #   assert_equal 2, z_cli['active']
  #   assert_equal 2, z_cli['new']
  #   assert_equal 2, z_cli['total']

  #   assert_equal 2, z_ass['active']
  #   assert_equal 2, z_ass['new']
  #   assert_equal 2, z_ass['total']
  #   assert_equal 1, z_ass['ended']

  #   assert_equal 2, gl_vol['active']
  #   assert_equal 2, gl_vol['new']
  #   assert_equal 2, gl_vol['total']

  #   assert_equal 6, gl_cli['active']
  #   assert_equal 6, gl_cli['new']
  #   assert_equal 6, gl_cli['total']

  #   assert_equal 6, gl_ass['active']
  #   assert_equal 6, gl_ass['new']
  #   assert_equal 6, gl_ass['total']
  #   assert_equal 3, gl_ass['ended']

  #   assert_equal 2, group_off['active']
  #   assert_equal 2, group_off['new']
  #   assert_equal 2, group_off['total']
  #   assert_equal 2, group_off['ended']
  # end

  def main_setup_entities
    create_assignment_entity(:this_year_z, :volunteer_z, :client_z, @today.beginning_of_year + 2)
    create_assignment_entity(:this_year_g, :volunteer, :client, @today.beginning_of_year + 2)
    create_assignment_entity(:this_year_e, :volunteer_external, :client,
      @today.beginning_of_year + 2)

    create_group_offer_entity(:this_year, @today.beginning_of_year + 2, nil, @v_this_year_z,
      @v_this_year_g)

    create_assignment_entity(:last_year_z, :volunteer_z, :client_z, @year_ago,
      @year_ago.end_of_year - 2)
    create_assignment_entity(:last_year_g, :volunteer, :client, @year_ago,
      @year_ago.end_of_year - 2)
    create_assignment_entity(:last_year_e, :volunteer_external, :client, @year_ago,
      @year_ago.end_of_year - 2)

    create_group_offer_entity(:last_year,  @year_ago, @year_ago.end_of_year - 2, @v_last_year_z,
      @v_last_year_g)

    create_assignment_entity(:last_year_still_z, :volunteer_z, :client_z, @year_ago)
    create_assignment_entity(:last_year_still_g, :volunteer, :client, @year_ago)
    create_assignment_entity(:last_year_still_e, :volunteer_external, :client, @year_ago)

    create_group_offer_entity(:last_year_still,  @year_ago, nil, @v_last_year_still_z,
      @v_last_year_still_g)
  end

  def extract_results(report)
    report.report_content['global'].values_at('volunteers', 'clients', 'assignments') +
      report.report_content['zuerich'].values_at('volunteers', 'clients', 'assignments') +
      [report.report_content['group_offers']]
  end

  def create_assignment_entity(title, volunteer, client, start_date, end_date = nil)
    volunteer = create volunteer, created_at: start_date
    client = create client, user: @user, created_at: start_date
    assignment = create_assignment(title && "a_#{title}", volunteer, client, start_date, end_date)
    return [volunteer, client, assignment] unless title
    instance_variable_set("@c_#{title}", client)
    instance_variable_set("@v_#{title}", volunteer)
  end

  def create_group_offer_entity(title, start_date, end_date, *volunteers)
    category = create :group_offer_category, category_name: "Category #{title}"
    group_offer = create_group_offer(title, category, volunteers.size, start_date)
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
    return assignment unless title
    instance_variable_set("@#{title}", assignment)
  end

  def create_group_offer(title, group_offer_category, volunteer_count, start_date)
    group_offer = create :group_offer, group_offer_category: group_offer_category, title: title,
      necessary_volunteers: volunteer_count, created_at: start_date.to_date - 1
    return group_offer unless title
    instance_variable_set("@group_offer_#{title}", group_offer)
    group_offer
  end
end
