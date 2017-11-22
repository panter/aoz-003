require 'application_system_test_case'

class VolunteerApplicationsTest < ApplicationSystemTestCase
  setup do
    @user = create :user
    create :email_template, body: 'Liebe/r %<anrede> %<name>', subject: '%<anrede> %<name>'
  end

  test 'login page show link for volunteer application' do
    visit root_path

    assert page.has_current_path? new_user_session_path
    assert page.has_link? 'Do you want to register as a volunteer?'
  end

  test 'new volunteer application' do
    create(:group_offer_category, category_name: 'Culture')
    create(:group_offer_category, category_name: 'Training')
    create(:group_offer_category, category_name: 'German Course')
    create(:group_offer_category, category_name: 'Other Offer')
    create(:group_offer_category, category_name:
      'Kurzbegleitungen bei Wohnungsbezug in Zürich-Stadt')

    visit root_path
    click_link 'Do you want to register as a volunteer?'

    assert page.has_current_path? new_volunteer_application_path
    assert page.has_text? 'Volunteer Registration'
    fill_in 'First name', with: 'Vorname'
    fill_in 'Last name', with: 'Name'
    within '.volunteer_birth_year' do
      select('1980', from: 'Birth year')
    end
    select('Mrs.', from: 'Salutation')
    select('Syrian Arab Republic', from: 'Nationality')
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'
    fill_in 'Primary email', with: 'gurke@gurkenmail.com'
    fill_in 'Primary phone', with: '0123456789'
    fill_in 'Profession', with: 'Developer'
    fill_in 'Education', with: 'Gurke'
    fill_in 'What is your motivation to volunteer with migrants?', with: 'asfd'
    page.check('volunteer_experience')
    fill_in 'If you have any experiences with voluntary work, please describe here.',
      with: 'sdfsdfsdf'
    fill_in 'What do you expect from a person who would accompany you / your volunteer work?',
      with: 'asdf'
    fill_in 'Where do you see your strengths? (Social competencies that you could contribute to voluntary work)', with: 'asdf'
    fill_in 'What are your most important leisure interests?', with: 'asdf'
    page.check('Culture')
    page.check('Training')
    page.check('German Course')
    page.check('Other Offer')
    fill_in 'Description', with: 'Description'
    page.check('Kurzbegleitungen bei Wohnungsbezug in Zürich-Stadt')
    page.check('volunteer_weekend')
    fill_in 'Detailed Description', with: 'I am every two weeks available on tuesdays asdfasdf.'

    click_button 'Submit registration'

    assert_equal 1, ActionMailer::Base.deliveries.size
    mailer = ActionMailer::Base.deliveries.last
    mail_body = mailer.body.encoded

    assert_includes mail_body, 'Liebe/r Mrs. Vorname Name'
    refute_includes mail_body, '%<anrede> %<name>'
    assert_equal mailer.subject, 'Mrs. Vorname Name'

    assert page.has_current_path? thanks_volunteer_applications_path
    assert page.has_text? 'Thank you'
    assert page.has_text? 'Your registration has been successfully sent.'
    assert page.has_text? 'We will soon get back to you.'
  end

  test 'secondary phone not visible in the application form' do
    visit new_volunteer_application_path
    refute page.has_text? 'Secondary phone'
  end
end
