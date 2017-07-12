require 'test_helper'

class ClientTest < ActiveSupport::TestCase
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

  test 'clients need accompanying' do
    result = Client.need_accompanying
    assert_equal [@client], result.to_a
  end

  test 'a client with an assignment should not show up in without assignment' do
    @volunteer = create :volunteer
    @user = create :user
    @client.create_assignment!(volunteer: @volunteer, user: @user)
    result = Client.need_accompanying
    assert_equal [], result.to_a
  end
end
