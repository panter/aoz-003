require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  test "should contain the firstname" do
    should validate_presence_of(:firstname)
  end

  test "should contain the lastname" do
    should validate_presence_of(:lastname)
  end
end
