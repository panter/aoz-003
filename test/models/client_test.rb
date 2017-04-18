require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  context "associations" do
    should have_many(:language_skills)
    should have_many(:relatives)
    should belong_to(:user)
  end

  context "validations" do
    should validate_presence_of(:firstname)
    should validate_presence_of(:lastname)
  end
end
