require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  context 'associations' do
    should have_many(:language_skills)
    should have_many(:relatives)
    should have_many(:schedules)
    should belong_to(:user)
  end

  context 'validations' do
    should validate_presence_of(:first_name)
    should validate_presence_of(:last_name)
  end

  def setup
    @client = create :client, :with_relatives, :with_language_skills
  end

  test 'client invalid with required attributes is valid' do
    assert @client.valid?
  end

  test 'client invalid with no required attributes is invalid' do
    client = Client.new
    refute client.valid?
  end
end
