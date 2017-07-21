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
    @client.create_assignment!(volunteer: @volunteer, creator: @user)
    result = Client.need_accompanying
    assert_equal [], result.to_a
  end

  test 'schedules build correctly automaticly' do
    new_client = Client.new
    new_client.valid? # to kick build_schedules in callback
    assert_equal new_client.schedules.size, 21
  end

  test 'schedules size validaton checks for the right size' do
    new_client = create :client
    new_client.valid?
    new_client.schedules.push Schedule.new
    refute new_client.valid?
    assert new_client.errors.messages == { schedules: ['too many'] }
    new_client.schedules.delete_all
    new_client.schedules.push Schedule.new
    refute new_client.valid?
    assert new_client.errors.messages == { schedules: ['not enough'] }
  end

  test 'contact relation is build automaticly' do
    new_client = Client.new
    assert new_client.contact.present?
  end
end
