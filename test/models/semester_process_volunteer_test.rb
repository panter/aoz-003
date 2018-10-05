require 'test_helper'

class SemesterProcessVolunteerTest < ActiveSupport::TestCase
  test '#mission returns array with all kind of related assignment or group_assignments' do
    volunteer = create(:volunteer_with_user)
    assignment = create(:assignment, volunteer: volunteer)
    group_assignment = create(:group_assignment, volunteer: volunteer)
    subject = create(:semester_process_volunteer, volunteer: volunteer,
      semester_process_volunteer_missions: [
        build(:semester_process_volunteer_mission, mission: assignment),
        build(:semester_process_volunteer_mission, mission: group_assignment)
      ])

    result = subject.missions
    assert result.include? assignment
    assert result.include? group_assignment
  end
end
