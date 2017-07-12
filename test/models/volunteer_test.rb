require 'test_helper'

class VolunteerTest < ActiveSupport::TestCase
  def setup
    @volunteer = create :volunteer, :with_language_skills
  end

  test 'valid factory' do
    assert @volunteer.valid?
  end

  test 'schedules build correctly automaticly' do
    new_volunteer = Volunteer.new
    assert_equal new_volunteer.schedules.size, 21
  end

  test 'contact relation is build automaticly' do
    new_volunteer = Volunteer.new
    assert new_volunteer.contact.present?
  end

  test 'volunteers without clients' do
    result = Volunteer.without_clients
    assert_equal [@volunteer], result.to_a
  end

  test 'a volunteer with an assignment should not show up in without assignment' do
    @client = create :client
    @volunteer.create_assignment!(client: @client)
    result = Volunteer.without_clients
    assert_equal [], result.to_a
>>>>>>> without clients equivalent of need accompanying
  end
end
