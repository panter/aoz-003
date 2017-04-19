require 'test_helper'

class RelativeTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:client)
  end
end
