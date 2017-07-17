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
end
