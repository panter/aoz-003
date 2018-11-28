require 'test_helper'

class ReviewSemesterWithMultipleAssignmentsTest < ActionDispatch::IntegrationTest
  def setup
    @volunteer = create :volunteer
    create :assignment, volunteer: @volunteer, period_start: time_z(2017, 12, 2)
    create :group_assignment, volunteer: @volunteer, period_start: time_z(2017, 12, 2)
    login_as create :user
  end

  test 'review semester should contain all missions' do
    params = {
      semester_process: {
        kind: 'mail',
        semester: '2018, 1',
        subject: 'subject',
        body: 'body',
        semester_process_volunteers_attributes: {
          0 => {
            selected: 0,
            volunteer_id: @volunteer.id
          }
        }
      },
      commit: 'Semester Prozess erfassen',
      action: 'create',
      semester: '2018, 1'
    }
    assert_difference 'SemesterProcessVolunteer.count', 1 do
      post semester_processes_path, params: params
    end
    assert_equal SemesterProcessVolunteer.last.missions.count, 2
  end
end
