require 'test_helper'

class SemesterProcessVolunteerTest < ActiveSupport::TestCase
  def setup
    @volunteer = create(:volunteer_with_user)
    @assignment = create(:assignment, volunteer: @volunteer)
    @group_assignment = create(:group_assignment, volunteer: @volunteer)
    @subject = create(:semester_process_volunteer, volunteer: @volunteer)
  end

  test 'set responsible also sets responsibility taken at' do
    @subject.update(responsible: create(:user))
    assert @subject.responsibility_taken_at.present?
  end
end
