require 'application_system_test_case'

class SemesterProcessVolunteersTest < ApplicationSystemTestCase
  setup do
    @current_semester = Semester.new
    @one_semester_back = create :semester_process, :with_volunteers, semester: @current_semester.previous_s
    @two_semesters_back = create :semester_process, :with_volunteers, semester: @current_semester.previous_s(2)
    @three_semesters_back = create :semester_process, :with_volunteers, semester: @current_semester.previous_s(3)
    login_as create(:user)
    visit semester_process_volunteers_path
  end

  test 'filter semester process volunteer shows previous semester by default' do
    assert page.has_text? @one_semester_back.semester_process_volunteers.first.semester_feedbacks.first.goals
    assert_not page.has_text? @two_semesters_back.semester_process_volunteers.first.semester_feedbacks.first.goals
  end

  test 'filter semester process volunteer on semester' do
    click_button "Semester: #{@current_semester.previous_s[0..3]},#{@current_semester.previous_s[5]}", match: :first
    click_link "#{@current_semester.previous_s(2)[5]}. Semester #{@current_semester.previous_s(2)[0..3]}"
    assert_not page.has_text? @one_semester_back.semester_process_volunteers.first.semester_feedbacks.first.goals
    assert page.has_text? @two_semesters_back.semester_process_volunteers.first.semester_feedbacks.first.goals
    assert_not page.has_text? @three_semesters_back.semester_process_volunteers.first.semester_feedbacks.first.goals
  end
end
