require 'test_helper'

class GroupOfferCategoryTest < ActiveSupport::TestCase
  def setup
    @category = create :group_offer_category
  end

  test 'group offer category is valid' do
    assert @category.valid?
  end

  test 'group offer category state field is default active' do
    assert_equal 'active', @category.category_state
  end
end
