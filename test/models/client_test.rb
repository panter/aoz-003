require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  context 'associations' do
    should have_many(:language_skills)
    should have_many(:relatives)
    should belong_to(:user)
  end

  context 'validations' do
    should validate_presence_of(:first_name)
    should validate_presence_of(:last_name)
  end
end
