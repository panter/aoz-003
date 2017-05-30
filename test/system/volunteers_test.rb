require 'application_system_test_case'

class VolunteersTest < ApplicationSystemTestCase
  setup do
    @user = create :user, :with_profile, email: 'superadmin@example.com'
    login_as @user
  end

  test 'new volunteer form' do
    visit new_volunteer_path

    fill_in 'First name', with: 'Volunteer'
    fill_in 'Last name', with: 'aoz'
    within '.volunteer_date_of_birth' do
      select_date all('select'), '28', 'May', '1988'
    end
    page.choose('volunteer_gender_female')
    select('Syrian Arab Republic', from: 'Nationality')
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'
    fill_in 'Email', with: 'gurke@gurkenmail.ch'
    fill_in 'Phone', with: '0123456789'
    click_on('Add language')
    select('Greek', from: 'Language')
    select('Native speaker', from: 'Level')
    click_on('Add family member')
    within '#relatives' do
      fill_in 'First name', with: 'asdf'
      fill_in 'Last name', with: 'asdf'
      select_date page.all('select'), '7', 'May', '1992'
    end
    fill_in 'Profession', with: 'Developer'
    fill_in 'Education', with: 'CEID'
    fill_in 'What is your motivation to volunteer with migrants?', with: 'asfd'
    page.check('volunteer_experience')
    fill_in 'What do you expect from a person who would accompany you / your volunteer work?', with: 'asdf'
    fill_in 'Where do you see your strengths? (Social competencies that you could contribute to voluntary work)', with: 'asdf'
    fill_in 'Professional skills that you could bring?', with: 'asdf'
    fill_in 'What are your most important leisure interests?', with: 'asdf'
    page.choose('volunteer_duration_short')
    page.check('volunteer_family')
    page.check('volunteer_training')
    page.check('volunteer_adults')
    page.choose('volunteer_region_canton')
    page.check('volunteer_schedules_attributes_17_available')

    click_button 'Create Volunteer'
    assert page.has_text? 'Volunteer was successfully created.'
  end

  test 'if required fields are left blank' do
    visit new_volunteer_path
    click_button 'Create Volunteer'
    assert page.has_text? 'Please review the problems below:'
    within '.volunteer_first_name' do
      assert page.has_text? "can't be blank"
    end
    within '.volunteer_last_name' do
      assert page.has_text? "can't be blank"
    end
    within '.volunteer_email' do
      assert page.has_text? "can't be blank"
    end
  end

  test 'rejection fields are shown only when the volunteer is rejected' do
    volunteer = create :volunteer
    visit volunteer_path(volunteer)
    refute page.has_content? 'Reason for rejection'
    refute page.has_content? 'Explanation for rejection'

    visit edit_volunteer_path(volunteer)
    refute page.has_content? 'Reason for rejection'
    refute page.has_field? 'Explanation for rejection'
    select('Rejected', from: 'State')
    assert page.has_content? 'Reason for rejection'
    assert page.has_field? 'Explanation for rejection'
    click_button 'Update Volunteer'

    visit volunteer_path(volunteer)
    assert page.has_content? 'Reason for rejection'
    assert page.has_content? 'Explanation for rejection'
  end
end
