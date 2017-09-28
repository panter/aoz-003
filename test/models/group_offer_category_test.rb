require 'test_helper'

class GroupOfferCategoryTest < ActiveSupport::TestCase
  test 'group offer category is valid' do
    category = GroupOfferCategory.create!(category_state: 'active', category_name: 'bogus category')
    assert_equal 1, GroupOfferCategory.count
    assert category.valid?
  end

  test 'group offer category state field is default active' do
    category = GroupOfferCategory.create!(category_state: 'active', category_name: 'bogus category')
    assert_equal 1, GroupOfferCategory.count
    assert_equal 'active', category.category_state
  end
end
