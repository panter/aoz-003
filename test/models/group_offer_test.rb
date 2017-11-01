require 'test_helper'

class GroupOfferTest < ActiveSupport::TestCase
  def setup
    @department_manager = create :user, role: 'department_manager'
    @department = create :department
    @foreign_department = create :department
    @category = create :group_offer_category
  end

  test 'department manager with no department cannot create group offer' do
    group_offer = GroupOffer.new creator: @department_manager, title: 'bogus_title', group_offer_category: @category
    refute group_offer.valid?
    assert_equal  ["can't be blank"],group_offer.errors.messages[:department]
    group_offer.department = @department
    refute group_offer.valid?
    assert_equal(
      ['Department manager müssen einem Standort zugeteilt sein, bevor sie Group offers erfassen können.'],
      group_offer.errors.messages[:creator_no_department]
    )
  end

  test 'group offer with department manager expects department to be set' do
    @department_manager.department = [@foreign_department]
    @department_manager.save
    group_offer = GroupOffer.new creator: @department_manager, title: 'bogus_title', group_offer_category: @category
    refute group_offer.valid?
    assert_equal ["can't be blank"], group_offer.errors.messages[:department]
  end

  test 'department manager with wrong department cannot create group offer' do
    @department_manager.department = [@foreign_department]
    @department_manager.save
    group_offer = GroupOffer.new(creator: @department_manager, title: 'bogus_title', department: @department,
                                 group_offer_category: @category)
    refute group_offer.valid?
    assert_equal ['Nicht der richtige Standort.'], group_offer.errors.messages[:creator_wrong_department]
  end

  test 'department manager with right department can create group offer' do
    @department_manager.department = [@department]
    @department_manager.save
    group_offer = GroupOffer.new(creator: @department_manager, title: 'bogus_title', department: @department,
                                 group_offer_category: @category)
    assert group_offer.valid?
  end
end
