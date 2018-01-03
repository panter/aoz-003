require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  def setup
    # client is by default accepted
    @client = create :client, :with_relatives, :with_language_skills
  end

  test 'client invalid with required attributes is valid' do
    assert @client.valid?
  end

  test 'client invalid with no required attributes is invalid' do
    client = Client.new
    refute client.valid?
  end

  test 'a client without assignment should show up in need accompanying' do
    result = Client.need_accompanying
    assert_equal [@client], result.to_a
  end

  test 'a client with an active assignment should not show up in need accompanying' do
    create :assignment_active, client: @client
    result = Client.need_accompanying
    assert_equal [], result.to_a
  end

  test 'a client with an inactive assignment should show up in need accompanying' do
    client = create :client
    create :assignment_inactive, client: client
    result = Client.need_accompanying
    assert_equal [@client, client], result.to_a
  end

  test 'contact relation is build automatically' do
    new_client = Client.new
    assert new_client.contact.present?
  end
end
