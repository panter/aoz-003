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
end
