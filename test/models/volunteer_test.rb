require 'test_helper'

class VolunteerTest < ActiveSupport::TestCase
  def setup
    @volunteer = create :volunteer, :with_relatives, :with_language_skills
  end

  test 'valid factory' do
    assert @volunteer.valid?
  end
end
