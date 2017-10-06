require 'test_helper'

class GroupOfferCategoryTest < ActiveSupport::TestCase
  def setup
    @today = Time.zone.today
    @year_ago = 1.year.ago.to_date
    @user = create :user

    create_stat_entity(nil, :volunteer_z, :client_z, @today.beginning_of_year + 2)
    create_stat_entity(nil, :volunteer, :client, @today.beginning_of_year + 2)
    create_stat_entity(nil, :volunteer_external, :client, @today.beginning_of_year + 2)

    create_stat_entity(nil, :volunteer_z, :client_z, @year_ago, @year_ago.end_of_year - 2)
    create_stat_entity(nil, :volunteer, :client, @year_ago, @year_ago.end_of_year - 2)
    create_stat_entity(nil, :volunteer_external, :client, @year_ago, @year_ago.end_of_year - 2)

    create_stat_entity(nil, :volunteer_z, :client_z, @year_ago)
    create_stat_entity(nil, :volunteer, :client, @year_ago)
    create_stat_entity(nil, :volunteer_external, :client, @year_ago)
  end

  test 'this year report' do
    report_this_year = PerformanceReport.create!(period_start: @today.beginning_of_year,
      period_end: @today.end_of_year, user: @user)
    g_vol, g_cli, g_ass, z_vol, z_cli, z_ass = extract_results(report_this_year)

    assert_equal 2, z_vol['active']
    assert_equal 1, z_vol['new']
    assert_equal 3, z_vol['total']

    assert_equal 2, z_cli['active']
    assert_equal 1, z_cli['new']
    assert_equal 3, z_cli['total']

    assert_equal 2, z_ass['active']
    assert_equal 1, z_ass['new']
    assert_equal 3, z_ass['total']
    assert_equal 0, z_ass['ended']

    assert_equal 4, g_vol['active']
    assert_equal 2, g_vol['new']
    assert_equal 6, g_vol['total']

    assert_equal 6, g_cli['active']
    assert_equal 3, g_cli['new']
    assert_equal 9, g_cli['total']

    assert_equal 6, g_ass['active']
    assert_equal 3, g_ass['new']
    assert_equal 9, g_ass['total']
    assert_equal 0, g_ass['ended']
  end

  test 'last year report' do
    report_last_year = PerformanceReport.create!(period_start: @year_ago.beginning_of_year,
      period_end: @year_ago.end_of_year, user: @user)
    g_vol, g_cli, g_ass, z_vol, z_cli, z_ass = extract_results(report_last_year)

    assert_equal 2, z_vol['active']
    assert_equal 2, z_vol['new']
    assert_equal 2, z_vol['total']

    assert_equal 2, z_cli['active']
    assert_equal 2, z_cli['new']
    assert_equal 2, z_cli['total']

    assert_equal 2, z_ass['active']
    assert_equal 2, z_ass['new']
    assert_equal 2, z_ass['total']
    assert_equal 1, z_ass['ended']

    assert_equal 4, g_vol['active']
    assert_equal 4, g_vol['new']
    assert_equal 4, g_vol['total']

    assert_equal 6, g_cli['active']
    assert_equal 6, g_cli['new']
    assert_equal 6, g_cli['total']

    assert_equal 6, g_ass['active']
    assert_equal 6, g_ass['new']
    assert_equal 6, g_ass['total']
    assert_equal 3, g_ass['ended']
  end

  test 'this year extern report' do
    report_this_year_extern = PerformanceReport.create!(period_start: @today.beginning_of_year,
      period_end: @today.end_of_year, user: @user, extern: true)
    g_vol, g_cli, g_ass, z_vol, z_cli, z_ass = extract_results(report_this_year_extern)

    assert_equal 0, z_vol['active']
    assert_equal 0, z_vol['new']
    assert_equal 0, z_vol['total']

    assert_equal 2, z_cli['active']
    assert_equal 1, z_cli['new']
    assert_equal 3, z_cli['total']

    assert_equal 2, z_ass['active']
    assert_equal 1, z_ass['new']
    assert_equal 3, z_ass['total']
    assert_equal 0, z_ass['ended']

    assert_equal 2, g_vol['active']
    assert_equal 1, g_vol['new']
    assert_equal 3, g_vol['total']

    assert_equal 6, g_cli['active']
    assert_equal 3, g_cli['new']
    assert_equal 9, g_cli['total']

    assert_equal 6, g_ass['active']
    assert_equal 3, g_ass['new']
    assert_equal 9, g_ass['total']
    assert_equal 0, g_ass['ended']
  end

  test 'last year extern report' do
    report_last_year_extern = PerformanceReport.create!(period_start: @year_ago.beginning_of_year,
      period_end: @year_ago.end_of_year, user: @user, extern: true)
    g_vol, g_cli, g_ass, z_vol, z_cli, z_ass = extract_results(report_last_year_extern)

    assert_equal 0, z_vol['active']
    assert_equal 0, z_vol['new']
    assert_equal 0, z_vol['total']

    assert_equal 2, z_cli['active']
    assert_equal 2, z_cli['new']
    assert_equal 2, z_cli['total']

    assert_equal 2, z_ass['active']
    assert_equal 2, z_ass['new']
    assert_equal 2, z_ass['total']
    assert_equal 1, z_ass['ended']

    assert_equal 2, g_vol['active']
    assert_equal 2, g_vol['new']
    assert_equal 2, g_vol['total']

    assert_equal 6, g_cli['active']
    assert_equal 6, g_cli['new']
    assert_equal 6, g_cli['total']

    assert_equal 6, g_ass['active']
    assert_equal 6, g_ass['new']
    assert_equal 6, g_ass['total']
    assert_equal 3, g_ass['ended']
  end

  def extract_results(report)
    report.report_content['global'].values_at('volunteers', 'clients', 'assignments') +
      report.report_content['zuerich'].values_at('volunteers', 'clients', 'assignments')
  end

  def create_stat_entity(title, volunteer, client, start_date, end_date = nil)
    volunteer = create volunteer, created_at: start_date
    client = create client, user: @user, created_at: start_date
    assignment = create_assignment(title && "a_#{title}", volunteer, client, start_date, end_date)
    return [volunteer, client, assignment] unless title
    instance_variable_set("@c_#{title}", client)
    instance_variable_set("@v_#{title}", volunteer)
  end

  def create_assignment(title, volunteer, client, period_start = nil, period_end = nil)
    period_start ||= @today.beginning_of_year
    assignment = create :assignment, volunteer: volunteer, client: client, creator: @user,
      period_start: period_start, period_end: period_end, created_at: period_start
    return assignment unless title
    instance_variable_set("@#{title}", assignment)
  end
end
