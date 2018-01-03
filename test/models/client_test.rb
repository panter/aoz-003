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

  test 'a client with an active assignment should not show up in need accompanying' do
    @client.create_assignment!(volunteer: create(:volunteer), creator: create(:user),
      period_start: 10.days.ago, period_end: nil)
    result = Client.need_accompanying
    assert_equal [], result.to_a
  end

  test 'a client with an inactive assignment should show up in need accompanying' do
    client = create :client
    client.create_assignment!(volunteer: create(:volunteer), creator: create(:user),
      period_start: 10.days.ago, period_end: 2.days.ago)
    result = Client.need_accompanying
    assert_equal [@client, client], result.to_a
  end

  test 'contact relation is build automaticly' do
    new_client = Client.new
    assert new_client.contact.present?
  end
end
