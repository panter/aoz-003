require 'test_helper'

class GroupOfferScopesTest < ActiveSupport::TestCase
  test 'active' do
    group_offer_active = create :group_offer, active: true
    group_offer_not_active = create :group_offer, active: false
    query = GroupOffer.active
    assert_includes query, group_offer_active
    refute_includes query, group_offer_not_active
  end

  test 'inactive' do
    group_offer_active = create :group_offer, active: true
    group_offer_inactive = create :group_offer, active: false
    query = GroupOffer.inactive
    refute_includes query, group_offer_active
    assert_includes query, group_offer_inactive
  end

  test 'internal_external' do
    internal = create :group_offer
    external = create :group_offer, :external

    assert_includes GroupOffer.internal, internal
    refute_includes GroupOffer.internal, external

    assert_includes GroupOffer.external, external
    refute_includes GroupOffer.external, internal
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
    assert_includes query, started_within_no_end
    assert_includes query, started_within_end_within
    assert_includes query, started_within_end_after
    assert_includes query, started_before_no_end
    assert_includes query, started_before_end_after
    assert_includes query, started_before_end_within
    refute_includes query, started_after_no_end
    refute_includes query, started_before_end_before

    started_before_end_before.update(necessary_volunteers: started_before_end_before.necessary_volunteers + 1)
    create_group_assignments(started_before_end_before, 45.days.ago, 10.days.ago, create(:volunteer))

    query = GroupOffer.active_group_assignments_between(45.days.ago, 30.days.ago)

    assert_includes query, started_before_end_before
  end

  test 'created_before' do
    created_after, _rest = create_group_offer_entity(nil, 40.days.ago, nil, 1)
    created_before, _rest = create_group_offer_entity(nil, 100.days.ago, 10.days.ago, 1)
    query = GroupOffer.created_before(50.days.ago)
    assert_includes query, created_before
    refute_includes query, created_after
  end

  test 'terminated' do
    terminated_go = create :group_offer, :terminated
    unterminated_go = create :group_offer
    query = GroupOffer.terminated
    assert_includes query, terminated_go
    refute_includes query, unterminated_go
  end
end
