require 'test_helper'
require 'ostruct'
require 'performance_report_generator'

class GroupOfferCategoryTest < ActiveSupport::TestCase
  include PerformanceReportGenerator

  def setup
    @today = Time.zone.today
    @year_ago = 1.year.ago.to_date
    @user = create :user
  end

  test 'group offer counts' do
    [GroupAssignment, GroupOffer, Assignment, Volunteer].map do |model|
      model.with_deleted.map(&:really_destroy!)
    end
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
end
