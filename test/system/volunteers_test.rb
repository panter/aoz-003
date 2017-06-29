require 'application_system_test_case'

class VolunteersTest < ApplicationSystemTestCase
  setup do
    @user = create :user, :with_profile, email: 'superadmin@example.com'
    login_as @user
    Volunteer.state_collection.each do |s|
      create :volunteer, state: s.to_s
    end
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
    click_link 'Add Email address'
    fill_in 'Email address', with: 'gurke@gurkenmail.com'
    click_link 'Add Phone number'
    fill_in 'Phone number', with: '0123456789'
    fill_in 'Profession', with: 'Developer'
    fill_in 'Education', with: 'CEID'
    fill_in 'What is your motivation to volunteer with migrants?', with: 'asfd'
    page.check('volunteer_experience')
    fill_in 'What do you expect from a person who would accompany you', with: 'asdf'
    fill_in 'Where do you see your strengths?', with: 'asdf'
    fill_in 'What are your most important leisure interests?', with: 'asdf'
    page.choose('volunteer_duration_short')
    page.choose('volunteer_region_region')
    page.check('volunteer_family')
    page.check('volunteer_training')
    page.check('volunteer_adults')
    page.choose('volunteer_region_canton')
    page.check('volunteer_schedules_attributes_17_available')

    click_button 'Create Volunteer'
    assert page.has_text? 'Volunteer was successfully created.'
  end

  test 'rejection fields are shown only when the volunteer is rejected' do
    visit new_volunteer_path
    refute page.has_text? 'Reason for rejection'
    refute page.has_field? 'Explanation for rejection'

    volunteer = create :volunteer

    visit volunteer_path(volunteer)
    refute page.has_text? 'Reason for rejection'
    refute page.has_text? 'Explanation for rejection'

    visit edit_volunteer_path(volunteer)
    refute page.has_text? 'Reason for rejection'
    refute page.has_field? 'Explanation for rejection'
    select('Rejected', from: 'State')
    assert page.has_content? 'Reason for rejection'
    assert page.has_field? 'Explanation for rejection'
    click_button 'Update Volunteer'

    visit volunteer_path(volunteer)
    assert page.has_content? 'Reason for rejection'
    assert page.has_content? 'Explanation for rejection'
  end

  test 'change filter to other options' do
    create :volunteer, state: 'resigned'
    visit volunteers_path
    within find_all('.btn-group').first do
      click_button 'State : All'
      click_link 'Terminated'
    end
    within 'tbody' do
      assert page.has_text? 'Terminated'
    end
  end

  test 'thead state filter dropdown can switch to all' do
    visit volunteers_path
    within 'tbody' do
      assert page.has_text? 'Interested'
      assert page.has_text? 'Contacted'
      assert page.has_text? 'Active'
      assert page.has_text? 'Accepted'
      assert page.has_text? 'Active and interested in further engagements'
      assert page.has_text? 'Rejected'
      assert page.has_text? 'Terminated'
      assert page.has_text? 'Looking for new engagement'
    end
  end

  test 'volunteer form has working_percent field' do
    visit edit_volunteer_path(Volunteer.first)
    assert page.has_field? 'Employment rate'
  end
end
