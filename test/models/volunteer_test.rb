require 'test_helper'

class VolunteerTest < ActiveSupport::TestCase
  def setup
    @volunteer = build :volunteer
  end

  test 'valid factory' do
    assert @volunteer.valid?
  end

  test 'voluntary with no required attributes is invalid' do
    volunteer = Volunteer.new
    refute volunteer.valid?
  end

  test 'record still exists after deletion' do
    volunteer = create :volunteer

    assert_difference 'Volunteer.count', -1 do
      volunteer.destroy
    end

    assert Volunteer.unscoped.find(volunteer.id)
  end
end
