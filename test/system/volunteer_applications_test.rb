require 'application_system_test_case'

class VolunteerApplicationsTest < ApplicationSystemTestCase
  setup do
    @user = create :user
  end

  test 'login page show link for volunteer application' do
    visit root_path

    assert page.has_current_path? new_user_session_path
    assert page.has_link? 'Möchten Sie sich als Freiwillige/r anmelden?'
  end

  test 'new volunteer application' do
    create :email_template, :signup
    create(:group_offer_category, category_name: 'Culture')
    create(:group_offer_category, category_name: 'Training')
    create(:group_offer_category, category_name: 'German Course')
    create(:group_offer_category, category_name: 'Other Offer')
    create(:group_offer_category, category_name:
      'Kurzbegleitungen bei Wohnungsbezug in Zürich-Stadt')

    visit root_path
    click_link 'Möchten Sie sich als Freiwillige/r anmelden?'

    assert page.has_current_path? new_volunteer_application_path
    assert_text 'Freiwilligen Anmeldung'
    fill_in 'Vorname', with: 'Vorname'
    fill_in 'Nachname', with: 'Name'
    page.execute_script("$('#volunteer_birth_year').val('01/01/1988')")
    select('Frau', from: 'Anrede')
    select('Syrien, Arabische Republik', from: 'Nationalität')
    fill_in 'Strasse', with: 'Sihlstrasse 131'
    fill_in 'PLZ', with: '8002'
    fill_in 'Ort', with: 'Zürich'
    fill_in 'Mailadresse', with: 'gurke@gurkenmail.com'
    fill_in 'Telefonnummer', with: '0123456789'
    fill_in 'Beruf', with: 'Developer'
    fill_in 'Ausbildung', with: 'Gurke'
    fill_in 'Was ist Ihre Motivation, Freiwilligenarbeit mit Migrant/innen zu leisten?', with: 'asfd'
    check('volunteer_experience')
    fill_in 'Falls Sie bereits Erfahrungen mit Freiwilligenarbeit haben, bitte diese genauer erläutern.',
            with: 'sdfsdfsdf'
    fill_in 'Was erwarten Sie von einer Person, die Sie begleiten würden / Ihrem Freiwilligeneinsatz?',
            with: 'asdf'
    fill_in 'Welche Stärken oder Kompetenzen (sozial, beruflich) könnten Sie in Ihre Freiwilligenarbeit einbringen?', with: 'asdf'
    fill_in 'Welche sind Ihre wichtigsten Freizeitinteressen?', with: 'asdf'
    check('Culture')
    check('Training')
    check('German Course')
    check('Other Offer')
    check('Kurzbegleitungen bei Wohnungsbezug in Zürich-Stadt')
    check('volunteer_weekend')
    fill_in 'Genauere Angaben', with: 'I am every two weeks available on tuesdays asdfasdf.'

    # ensure the assertation for count doesn't fail further down
    ActionMailer::Base.deliveries.clear

    click_button 'Anmeldung abschicken'
    assert_text 'Vielen Dank für Ihre Anmeldung'

    assert_equal 1, ActionMailer::Base.deliveries.size
    mailer = ActionMailer::Base.deliveries.last
    assert_equal 'Vielen Dank für Ihre Anmeldung', mailer.subject

    assert page.has_current_path? thanks_volunteer_applications_path
  end

  test "volunteer see's thankyou page with content from signup email template" do
    create :email_template, :signup
    @email_template1 = create :email_template, kind: :signup, active: true
    @email_template2 = create :email_template, kind: :signup, active: false, subject: 'Hoi', body: 'Wadap?'
    visit thanks_volunteer_applications_path

    # thanks page takes body text from active template
    assert_text @email_template1.subject
    assert_text @email_template1.body

    refute_text 'Howdy', wait: 0
    refute_text 'Wadap?', wait: 0

    # ensure text is updated when another template is set to active
    @email_template2.update(active: true)
    visit thanks_volunteer_applications_path
    assert_text 'Hoi'
    assert_text 'Wadap?'

    refute_text @email_template1.subject, wait: 0
    refute_text @email_template1.body, wait: 0
  end

  test 'secondary phone not visible in the application form' do
    visit new_volunteer_application_path
    assert_text 'Freiwilligen Anmeldung'
    refute_field 'Telefonnummer 2', wait: 0
  end
end
