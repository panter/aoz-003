require 'test_helper'

class GroupOfferScopesTest < ActiveSupport::TestCase
  test 'active' do
    group_offer_active = create :group_offer, active: true
    group_offer_not_active = create :group_offer, active: false
    query = GroupOffer.active
    assert query.include? group_offer_active
    refute query.include? group_offer_not_active
  end

  test 'inactive' do
    group_offer_active = create :group_offer, active: true
    group_offer_not_active = create :group_offer, active: false
    query = GroupOffer.inactive
    refute query.include? group_offer_active
    assert query.include? group_offer_not_active
  end

  test 'in_department' do
    in_department = create :group_offer, department: create(:department)
    outside_department = create :group_offer
    query = GroupOffer.in_department
    assert query.include? in_department
    refute query.include? outside_department
  end

  test 'active_group_assignments_between' do
    started_within_no_end, _rest = create_group_offer_entity(nil, 40.days.ago, nil, 1)
    started_within_end_within, _rest = create_group_offer_entity(nil, 40.days.ago, 30.days.ago, 1)
    started_within_end_after, _rest = create_group_offer_entity(nil, 40.days.ago, 10.days.ago, 1)

    started_before_no_end, _rest = create_group_offer_entity(nil, 100.days.ago, nil, 1)
    started_after_no_end, _rest = create_group_offer_entity(nil, 10.days.ago, nil, 1)

    started_before_end_after, _rest = create_group_offer_entity(nil, 100.days.ago, 10.days.ago, 1)
    started_before_end_within, _rest = create_group_offer_entity(nil, 100.days.ago, 35.days.ago, 1)
    started_before_end_before, _rest = create_group_offer_entity(nil, 100.days.ago, 50.days.ago, 1)

    query = GroupOffer.active_group_assignments_between(45.days.ago, 30.days.ago)

    assert query.include? started_within_no_end
    assert query.include? started_within_end_within
    assert query.include? started_within_end_after
    assert query.include? started_before_no_end
    assert query.include? started_before_end_after
    assert query.include? started_before_end_within
    refute query.include? started_after_no_end
    refute query.include? started_before_end_before

    started_before_end_before.update(necessary_volunteers: started_before_end_before.necessary_volunteers + 1)
    create_group_assignments(started_before_end_before, 45.days.ago, 10.days.ago, create(:volunteer))

    query = GroupOffer.active_group_assignments_between(45.days.ago, 30.days.ago)

    assert query.include? started_before_end_before
  end

  test 'created_before' do
    created_after, _rest = create_group_offer_entity(nil, 40.days.ago, nil, 1)
    created_before, _rest = create_group_offer_entity(nil, 100.days.ago, 10.days.ago, 1)
    query = GroupOffer.created_before(50.days.ago)
    assert query.include? created_before
    refute query.include? created_after
  end
end
