require 'test_helper'

class GroupOfferValidationTest < ActiveSupport::TestCase
  test 'group_offer_with_running_group_assignments_cannot_get_period_end_set' do
    group_offer = create :group_offer
    group_assignment1 = create :group_assignment, period_start: 1.year.ago, period_end: nil,
      group_offer: group_offer
    create :group_assignment, period_start: 6.months.ago, period_end: nil,
      group_offer: group_offer
    group_offer.period_end = Time.zone.now
    refute group_offer.valid?
    assert_equal 'Dieses Gruppenangebot kann noch nicht beendet werden, da es noch 2 laufende '\
      'Gruppeneinsätze hat.', group_offer.errors.messages[:period_end].first
    group_assignment1.update(period_end: 2.days.ago)
    refute group_offer.valid?
    assert_equal 'Dieses Gruppenangebot kann noch nicht beendet werden, da es noch 1 laufende '\
      'Gruppeneinsätze hat.', group_offer.errors.messages[:period_end].first
    group_assignment1.update(period_end: 2.days.ago)
    group_offer.reload
    assert group_offer.valid?
  end

  test 'group_offer_requires_location_fields' do
    group_offer = build :group_offer
    group_offer.offer_type = 'internal_offer'
    group_offer.department = nil

    refute group_offer.valid?
    assert_includes group_offer.errors, :department
    refute_includes group_offer.errors, :organization
    refute_includes group_offer.errors, :location

    group_offer.offer_type = 'external_offer'

    refute group_offer.valid?
    refute_includes group_offer.errors, :department
    assert_includes group_offer.errors, :organization
    assert_includes group_offer.errors, :location
  end
end
