require 'test_helper'

class GroupAssignmentScopesTest < ActiveSupport::TestCase
  def setup
    @volunteer_one = create :volunteer
    @volunteer_two = create :volunteer
    @group_offer_one = create :group_offer, necessary_volunteers: 20,
      group_offer_category: create(:group_offer_category)
    @group_offer_two = create :group_offer, necessary_volunteers: 20,
      group_offer_category: create(:group_offer_category)

    @started_no_end = GroupAssignment.create(volunteer: @volunteer_one,
      group_offer: @group_offer_one, period_start: 100.days.ago, period_end: nil)
    @starts_in_future_no_end = GroupAssignment.create(volunteer: @volunteer_two,
      group_offer: @group_offer_one, period_start: Time.zone.today + 100, period_end: nil)
    @started_and_ended = GroupAssignment.create(volunteer: @volunteer_one,
      group_offer: @group_offer_two, period_start: 100.days.ago, period_end: 20.days.ago)
    @started_20_d_ago_no_end = GroupAssignment.create(volunteer: @volunteer_two,
      group_offer: @group_offer_two, period_start: 20.days.ago, period_end: nil)
    @started_20_d_ago_end_future = GroupAssignment.create(volunteer: create(:volunteer), group_offer: @group_offer_two,
      period_start: 20.days.ago, period_end: Time.zone.today + 100)
  end

  test 'started' do
    query = GroupAssignment.started
    assert query.include? @started_no_end
    refute query.include? @starts_in_future_no_end
    assert query.include? @started_and_ended
    assert query.include? @started_20_d_ago_no_end
    assert query.include? @started_20_d_ago_end_future
  end

  test 'going_to_start' do
    query = GroupAssignment.going_to_start
    refute query.include? @started_no_end
    assert query.include? @starts_in_future_no_end
    refute query.include? @started_and_ended
    refute query.include? @started_20_d_ago_no_end
    refute query.include? @started_20_d_ago_end_future
  end

  test 'ongoing' do
    query = GroupAssignment.ongoing
    assert query.include? @started_no_end
    refute query.include? @starts_in_future_no_end
    refute query.include? @started_and_ended
    assert query.include? @started_20_d_ago_no_end
    assert query.include? @started_20_d_ago_end_future
  end

  test 'no_end' do
    query = GroupAssignment.no_end
    assert query.include? @started_no_end
    assert query.include? @starts_in_future_no_end
    refute query.include? @started_and_ended
    assert query.include? @started_20_d_ago_no_end
    refute query.include? @started_20_d_ago_end_future
  end

  test 'no_start' do
    no_start = GroupAssignment.create(group_offer: @group_offer_two, volunteer: create(:volunteer),
      period_start: nil, period_end: nil)
    no_start.update(period_start: nil)
    query = GroupAssignment.no_start
    assert query.include? no_start
    refute query.include? @started_no_end
    refute query.include? @starts_in_future_no_end
    refute query.include? @started_and_ended
    refute query.include? @started_20_d_ago_no_end
    refute query.include? @started_20_d_ago_end_future
  end

  test 'ended' do
    query = GroupAssignment.ended
    refute query.include? @started_no_end
    refute query.include? @starts_in_future_no_end
    assert query.include? @started_and_ended
    refute query.include? @started_20_d_ago_no_end
    refute query.include? @started_20_d_ago_end_future
  end

  test 'active' do
    query = GroupAssignment.active
    assert query.include? @started_no_end
    refute query.include? @starts_in_future_no_end
    refute query.include? @started_and_ended
    assert query.include? @started_20_d_ago_no_end
    assert query.include? @started_20_d_ago_end_future
  end

  test 'inactive' do
    query = GroupAssignment.inactive
    refute query.include? @started_no_end
    assert query.include? @starts_in_future_no_end
    assert query.include? @started_and_ended
    refute query.include? @started_20_d_ago_no_end
    refute query.include? @started_20_d_ago_end_future
  end
end
