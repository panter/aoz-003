require 'test_helper'

class GroupOfferTest < ActiveSupport::TestCase
  test 'terminated? method' do
    terminated = create :group_offer, :terminated
    unterminated = create :group_offer
    assert terminated.terminated?
    refute unterminated.terminated?
  end

  test 'terminatable? method' do
    terminatable = create :group_offer
    create :terminated_group_assignment, group_offer: terminatable
    unterminatable = create :group_offer
    create :group_assignment, group_offer: unterminatable, period_start: 2.months.ago,
      period_end: nil
    assert terminatable.terminatable?
    refute unterminatable.terminatable?
  end

  test 'terminated_and_active_group_offer_is_not_valid' do
    still_active = build :group_offer, period_end: 2.days.ago, period_end_set_by: create(:user)
    refute still_active.valid?
    assert still_active.errors.messages[:active].any?
    still_active.active = false
    assert still_active.valid?
  end
end
