require 'application_system_test_case'

class VolunteersTest < ApplicationSystemTestCase
  setup do
    @user = create :user, email: 'superadmin@example.com'
    login_as @user
    Volunteer.acceptance_collection.each do |acceptance|
      create :volunteer, acceptance: acceptance
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
    choose 'Rejected'
    assert page.has_content? 'Reason for rejection'
    page.choose('volunteer_rejection_type_other')
    assert page.has_field? 'Explanation for rejection'
    fill_in 'Explanation for rejection', with: 'Explanation'
    click_button 'Update Volunteer'

    visit volunteer_path(volunteer)
    assert page.has_content? 'Reason for rejection Other'
    assert page.has_content? 'Explanation for rejection Explanation'
  end

  test 'thead acceptance filter dropdown can switch to all' do
    visit volunteers_path
    within 'tbody' do
      assert page.has_text? 'Accepted'
      assert page.has_text? 'Undecided'
      assert page.has_text? 'Rejected'
      assert page.has_text? 'Resigned'
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
    Volunteer.with_deleted.map(&:really_destroy!)
    second_page_volunteers = (1..20).to_a.map do
      volunteer = create :volunteer
      volunteer.update created_at: 10.days.ago
      volunteer.contact.update(
        first_name: 'second_page',
        last_name: 'second_page' + volunteer.contact.last_name
      )
      volunteer
    end
    20.times do
      create :volunteer
    end
    visit volunteers_path
    first(:link, '2').click

    assert page.has_css? '.pagination'
    second_page_volunteers.each do |volunteer|
      assert page.has_text? volunteer.contact.last_name
    end
  end

  test 'volunteer (with assignments) index partial has no journal link' do
    volunteer = create :volunteer
    create :assignment, volunteer: volunteer
    visit volunteer_path(volunteer)
    refute page.has_link? 'Journal'
  end

  test 'department manager can see volunteer index and only seeking clients volunteers' do
    department_manager = create :department_manager
    login_as department_manager
    play_user_index_volunteer_display
  end

  test 'social worker can see volunteer index and only seeking clients volunteers' do
    social_worker = create :social_worker
    login_as social_worker
    play_user_index_volunteer_display
  end

  def play_user_index_volunteer_display
    volunteer_seeks = create :volunteer, user: create(:user_volunteer),
      assignments: [create(:assignment, period_start: 500.days.ago, period_end: 200.days.ago)]
    volunteer_not_seeking = create :volunteer, user: create(:user_volunteer),
      assignments: [create(:assignment, period_start: 10.days.ago, period_end: nil)]
    visit volunteers_path
    assert page.has_text? volunteer_seeks.contact.full_name
    refute page.has_text? volunteer_not_seeking.contact.full_name
  end
end
