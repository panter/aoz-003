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

    select('Mrs.', from: 'Salutation')
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
    fill_in 'Primary phone', with: '0123456789'
    fill_in 'Profession', with: 'Developer'
    fill_in 'Education', with: 'CEID'
    fill_in 'What is your motivation to volunteer with migrants?', with: 'asfd'
    page.check('volunteer_experience')
    fill_in 'What do you expect from a person who would accompany you', with: 'asdf'
    fill_in 'Where do you see your strengths?', with: 'asdf'
    fill_in 'What are your most important leisure interests?', with: 'asdf'
    page.check('volunteer_family')
    page.check('volunteer_training')
    page.check('volunteer_other_offer')
    fill_in 'Description', with: 'Description'
    page.check('volunteer_zurich')
    fill_in 'Bank', with: 'BankName'
    fill_in 'IBAN', with: 'CH01 2345 6789 0123 4567 8'
    page.check('volunteer_waive')
    page.check('volunteer_weekend')
    fill_in 'Detailed Description', with: 'I am every two weeks available on tuesdays asdfasdf.'

    click_button 'Create Volunteer'
    assert page.has_text? 'Volunteer was successfully created.'
  end

  test 'show volunteer custom nationality (nationality_name test)' do
    visit new_volunteer_path
    select('Mrs.', from: 'Salutation')
    fill_in 'First name', with: 'Volunteer'
    fill_in 'Last name', with: 'Volunteer'
    select('Kosovo', from: 'Nationality')
    fill_in 'Primary email', with: 'volunteer@kosovo.com'
    fill_in 'Primary phone', with: '0123456789'
    select('Mrs.', from: 'Salutation')
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'

    click_button 'Create Volunteer'

    assert page.has_text? 'Kosovo'
  end

  test 'show volunteer checklist' do
    visit new_volunteer_path
    select('Mrs.', from: 'Salutation')
    fill_in 'First name', with: 'Volunteer'
    fill_in 'Last name', with: 'Volunteer'
    fill_in 'Primary email', with: 'volunteer@kosovo.com'
    fill_in 'Primary phone', with: '0123456789'
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'

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
    select('Mrs.', from: 'Salutation')
    fill_in 'First name', with: 'Volunteer'
    fill_in 'Last name', with: 'Volunteer'
    fill_in 'Primary email', with: 'volunteer@kosovo.com'
    fill_in 'Primary phone', with: '0123456789'
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'

    click_button 'Create Volunteer'

    assert page.has_text? 'Trial period report No'
    assert page.has_text? 'Introductory course No'
    assert page.has_text? "Engaged volunteer's documents sent No"
    assert page.has_text? 'Bank account details entered No'
    assert page.has_text? 'Final evaluation No'
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
    page.choose('volunteer_rejection_type_other')
    assert page.has_field? 'Explanation for rejection'
    fill_in 'Explanation for rejection', with: 'Explanation'
    click_button 'Update Volunteer'

    visit volunteer_path(volunteer)
    assert page.has_content? 'Reason for rejection Other'
    assert page.has_content? 'Explanation for rejection Explanation'
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

  test 'volunteer has no secondary phone field' do
    visit new_volunteer_path
    refute page.has_text? 'Secondary phone'

    visit volunteer_path(Volunteer.first)
    refute page.has_text? 'Secondary phone'
  end

  test 'volunteer pagination' do
    70.times do
      create :volunteer
    end
    visit volunteers_path
    first(:link, '2').click

    assert page.has_css? '.pagination'
    Volunteer.paginate(page: 2).each do |volunteer|
      assert page.has_text? volunteer.contact.last_name
    end
  end
end
