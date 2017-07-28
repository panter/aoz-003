require 'application_system_test_case'

class VolunteersTest < ApplicationSystemTestCase
  setup do
    @user = create :user, email: 'superadmin@example.com'
    login_as @user
    Volunteer::STATES.each do |s|
      create :volunteer, state: s.to_s
    end
  end

  test 'new volunteer form' do
    visit new_volunteer_path

    fill_in 'First name', with: 'Volunteer'
    fill_in 'Last name', with: 'aoz'
    within '.volunteer_birth_year' do
      select('1988', from: 'Birth year')
    end
    select('Mrs.', from: 'Salutation')
    select('Syrian Arab Republic', from: 'Nationality')
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'
    fill_in 'Primary email', with: 'gurke@gurkenmail.com'
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

  test 'show volunteer custom nationality (nationality_name test)' do
    visit new_volunteer_path
    fill_in 'First name', with: 'Volunteer'
    fill_in 'Last name', with: 'Volunteer'
    select('Kosovo', from: 'Nationality')
    fill_in 'Primary email', with: 'volunteer@kosovo.com'

    click_button 'Create Volunteer'

    assert page.has_text? 'Kosovo'
  end

  test 'show volunteer checklist' do
    visit new_volunteer_path
    fill_in 'First name', with: 'Volunteer'
    fill_in 'Last name', with: 'Volunteer'
    fill_in 'Primary email', with: 'volunteer@kosovo.com'

    page.check('volunteer_trial_period')
    page.check('volunteer_intro_course')
    page.check('volunteer_doc_sent')
    page.check('volunteer_bank_account')
    page.check('volunteer_evaluation')

    click_button 'Create Volunteer'

    assert page.has_text? 'Trial period report Yes'
    assert page.has_text? 'Introductory course Yes'
    assert page.has_text? "Engaged volunteer's documents sent Yes"
    assert page.has_text? 'Bank account details entered Yes'
    assert page.has_text? 'Final evaluation Yes'
  end

  test 'volunteer checklist has default values (false)' do
    visit new_volunteer_path
    fill_in 'First name', with: 'Volunteer'
    fill_in 'Last name', with: 'Volunteer'
    fill_in 'Primary email', with: 'volunteer@kosovo.com'

    click_button 'Create Volunteer'

    assert page.has_text? 'Trial period report No'
    assert page.has_text? 'Introductory course No'
    assert page.has_text? "Engaged volunteer's documents sent No"
    assert page.has_text? 'Bank account details entered No'
    assert page.has_text? 'Final evaluation No'
  end

  test 'conditional field for radio button is shown on radio chosen' do
    visit new_volunteer_path
    refute page.has_field? 'volunteer_region_specific'
    page.choose('volunteer_region_city')
    refute page.has_field? 'volunteer_region_specific'
    page.choose('volunteer_region_region')
    assert page.has_field? 'volunteer_region_specific'
    page.choose('volunteer_region_canton')
    refute page.has_field? 'volunteer_region_specific'
  end

  test 'hidden conditional field is shown if edited volunteer radio is chosen' do
    volunteer = create :volunteer, region: 'region'
    visit edit_volunteer_path(volunteer)
    assert page.has_field? 'volunteer_region_specific'
  end

  test 'hidden group of conditional field is shown if one of other group checked' do
    visit new_volunteer_path
    refute page.has_field? 'volunteer_adults'
    refute page.has_field? 'volunteer_teenagers'
    refute page.has_text? 'Target groups'
    page.check('volunteer_german_course')
    assert page.has_field? 'volunteer_adults'
    assert page.has_field? 'volunteer_teenagers'
    assert page.has_text? 'Target groups'
    page.check('volunteer_training')
    assert page.has_field? 'volunteer_adults'
    page.uncheck('volunteer_german_course')
    assert page.has_field? 'volunteer_adults'
    page.uncheck('volunteer_training')
    refute page.has_field? 'volunteer_adults'
    refute page.has_field? 'volunteer_teenagers'
    refute page.has_text? 'Target groups'
  end

  test 'hidden group of conditional field is shown if field of edited volunteer is true' do
    volunteer = create :volunteer, training: true
    visit edit_volunteer_path(volunteer)
    assert page.has_field? 'volunteer_adults'
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
