require 'test_helper'

class GroupOfferValidationTest < ActiveSupport::TestCase
  test 'group_offer_with_running_group_assignments_cannot_get_period_end_set' do
    group_offer = create :group_offer
    group_assignment1 = create :group_assignment, period_start: 1.year.ago, period_end: nil,
      group_offer: group_offer
    group_assignment2 = create :group_assignment, period_start: 6.months.ago, period_end: nil,
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
end
