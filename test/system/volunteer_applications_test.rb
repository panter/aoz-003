require 'application_system_test_case'

class VolunteerApplicationsTest < ApplicationSystemTestCase
  setup do
    @user = create :user
  end

  test 'login page show link for volunteer application' do
    visit root_path

    assert page.has_current_path? new_user_session_path
    assert page.has_link? 'Do you want to apply as a volunteer?'
  end

  test 'new volunteer application' do
    visit root_path
    click_link 'Do you want to apply as a volunteer?'

    assert page.has_current_path? new_volunteer_application_path
    assert page.has_text? 'Volunteer Application'
    fill_in 'First name', with: 'Volunteer'
    fill_in 'Last name', with: 'Application'
    within '.volunteer_date_of_birth' do
      select_date all('select'), '13', 'February', '1980'
    end
    page.choose('volunteer_gender_female')
    select('Syrian Arab Republic', from: 'Nationality')
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'
    click_link 'Add Email address'
    fill_in 'Email address', with: 'gurke@gurkenmail.com'
    click_link 'Add Phone number'
    fill_in 'Phone number', with: '0123456789'
    fill_in 'Profession', with: 'Developer'
    fill_in 'Education', with: 'Gurke'
    fill_in 'What is your motivation to volunteer with migrants?', with: 'asfd'
    page.check('volunteer_experience')
    fill_in 'What do you expect from a person who would accompany you / your volunteer work?', with: 'asdf'
    fill_in 'Where do you see your strengths? (Social competencies that you could contribute to voluntary work)', with: 'asdf'
    fill_in 'What are your most important leisure interests?', with: 'asdf'
    page.choose('volunteer_duration_short')
    page.choose('volunteer_region_region')
    page.check('volunteer_culture')
    page.check('volunteer_training')
    page.check('volunteer_family')
    page.check('volunteer_training')
    page.check('volunteer_adults')
    page.choose('volunteer_region_canton')

    click_button 'Submit application'
    assert page.has_current_path? thanks_volunteer_applications_path
    assert page.has_text? 'Thank you'
    assert page.has_text? 'Your application has been successfully sent.'
    assert page.has_text? 'We will soon get back to you.'
  end

  test 'state field not visible in the application form' do
    visit new_volunteer_application_path
    assert_not page.has_text? 'State'
  end
end
