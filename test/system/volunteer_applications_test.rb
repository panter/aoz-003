require 'application_system_test_case'

class VolunteerApplicationsTest < ApplicationSystemTestCase
  setup do
    @user = create :user
    create :email_template,
      body: 'Liebe/r %{Anrede} %{Name} %{InvalidKey}Gruss, AOZ', subject: '%{Anrede} %{Name}'
  end

  test 'login page show link for volunteer application' do
    visit root_path

    assert page.has_current_path? new_user_session_path
    assert page.has_link? 'Möchten Sie sich als Freiwillige/r anmelden?'
  end

  test 'new volunteer application' do
    create(:group_offer_category, category_name: 'Culture')
    create(:group_offer_category, category_name: 'Training')
    create(:group_offer_category, category_name: 'German Course')
    create(:group_offer_category, category_name: 'Other Offer')
    create(:group_offer_category, category_name:
      'Kurzbegleitungen bei Wohnungsbezug in Zürich-Stadt')

    visit root_path
    click_link 'Möchten Sie sich als Freiwillige/r anmelden?'

    assert page.has_current_path? new_volunteer_application_path
    assert page.has_text? 'Freiwilligen Anmeldung'
    fill_in 'Vorname', with: 'Vorname'
    fill_in 'Nachname', with: 'Name'
    within '.volunteer_birth_year' do
      select('1980', from: 'Jahrgang')
    end
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
    page.check('volunteer_experience')
    fill_in 'Falls sie bereits Erfahrungen mit Freiwilligenarbeit haben, bitte diese genauer erläutern.',
      with: 'sdfsdfsdf'
    fill_in 'Was erwarten Sie von einer Person, die Sie begleiten würden / Ihrem Freiwilligeneinsatz?',
      with: 'asdf'
    fill_in 'Welche Stärken oder Kompetenzen (sozial, beruflich) könnten Sie in Ihre Freiwilligenarbeit einbringen?', with: 'asdf'
    fill_in 'Welche sind Ihre wichtigsten Freizeitinteressen?', with: 'asdf'
    page.check('Culture')
    page.check('Training')
    page.check('German Course')
    page.check('Other Offer')
    fill_in 'Beschreibung', with: 'Description'
    page.check('Kurzbegleitungen bei Wohnungsbezug in Zürich-Stadt')
    page.check('volunteer_weekend')
    fill_in 'Genauere Angaben', with: 'I am every two weeks available on tuesdays asdfasdf.'

    click_button 'Anmeldung abschicken'

    assert_equal 1, ActionMailer::Base.deliveries.size
    mailer = ActionMailer::Base.deliveries.last
    mail_body = mailer.text_part.body.encoded

    assert_equal 'Frau Vorname Name', mailer.subject
    assert_includes mail_body, 'Liebe/r Frau Vorname Name Gruss, AOZ'
    refute_includes mailer.subject, '%{'
    refute_includes mail_body, '%{'

    assert page.has_current_path? thanks_volunteer_applications_path
    assert page.has_text? 'Vielen Dank'
    assert page.has_text? 'Ihre Anmeldung wurde erfolgreich abgeschickt.'
    assert page.has_text? 'Wir werden uns bald bei Ihnen melden.'
  end

  test 'secondary phone not visible in the application form' do
    visit new_volunteer_application_path
    refute page.has_text? 'Telefonnummer 2'
  end
end
