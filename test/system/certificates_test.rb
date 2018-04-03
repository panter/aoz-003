require 'application_system_test_case'

class CertificatesTest < ApplicationSystemTestCase
  def setup
    @volunteer = create(:volunteer, :with_assignment, user: create(:user_volunteer))
    @assignment = @volunteer.assignments.first
    @hour = create :hour, volunteer: @volunteer, hourable: @assignment, hours: 2
    login_as create(:user)
  end

  test 'volunteer_user_cannot_see_create_certificate_button' do
    login_as @volunteer.user
    visit volunteer_path(@volunteer)
    refute page.has_link? 'Nachweis ausstellen'
  end

  test 'creating_volunteer_certificate_form_has_right_content_prefilled' do
    group_offer = create :group_offer, volunteers: [@volunteer]
    group_offer.group_assignments.last.update(period_start: 2.years.ago)
    visit volunteer_path(@volunteer)
    first(:link, 'Nachweis').click
    assert page.has_text? 'Nachweis erfassen'
    click_link('Nachweis erfassen')
    assert page.has_field? 'Text', text: 'Die **AOZ** ist ein Unternehmen der Stadt Zürich und'
    assert page.has_field? 'Stunden', with: 2.0
    click_button 'Weitere Felder anpassen'
    assert page.has_field? 'Tandem', checked: true, count: 1
    assert page.has_field? 'Name', with: @volunteer.contact.full_name
    assert page.find_field('Strasse').value.include? @volunteer.contact.street
    assert page.find_field('Ort').value.include? @volunteer.contact.city
    assert page.find_field('Funktion').value.include? 'Förderung der sozialen und beruflichen Integ'
    assert page.find_field('Institution').value.include? '**AOZ** Zürich, Flüelastrasse 32, 8047'
    page.find_button('Nachweis erfassen').click
    assert page.has_text? 'AOZ Zürich, Flüelastrasse 32, 8047'
    assert page.has_text? @volunteer.contact.full_name
    assert page.has_text? I18n.l(@volunteer.certificates.first.created_at.to_date)
    assert page.has_text? I18n.l(@volunteer.min_assignment_date)
    assert page.has_text? I18n.l(@volunteer.max_assignment_date)
    assert page.has_link? 'Ausdrucken'
  end

  test 'updating_certificate_with_custom_values' do
    visit new_volunteer_certificate_path(@volunteer)
    click_button 'Nachweis erfassen'

    assert page.has_text? 'Nachweis anzeigen'
    click_link 'Nachweis bearbeiten'

    fill_in 'Text', with: '**Bold** or not *bold*, that is this tests Question?<br>***both***'
    assert page.has_text? 'Nachweis bearbeiten'
    click_button 'Weitere Felder anpassen'
    assert page.has_field? 'Tandem', checked: true, count: 1
    fill_in 'Stunden', with: 555
    fill_in 'Name', with: 'This bogus test name'
    fill_in 'Institution', with: 'The Testology Institute'
    page.find_button('Nachweis aktualisieren').click
    assert page.has_text? '555'
    assert page.has_text? 'This bogus test name'
    assert page.has_text? 'The Testology Institute'
    assert page.has_text? 'Bold or not bold, that is this tests Question? both'
  end

  test 'show_certificate_has_tandem_only_once' do
    visit new_volunteer_certificate_path(@volunteer)
    click_button 'Nachweis erfassen'

    visit volunteer_certificate_path(@volunteer, @volunteer.certificates.last)
    assert page.has_text? 'Tandem', count: 1
  end

  test 'volunteer_that_has_only_group_offers_can_have_certificate' do
    volunteer = create :volunteer
    create :group_offer, volunteers: [volunteer]
    volunteer.group_assignments.last.update(period_start: 2.months.ago)

    visit volunteer_path(volunteer)
    first(:link, 'Nachweis').click
    click_link('Nachweis erfassen')
    assert page.has_text? 'ist ein Unternehmen der Stadt Zürich'
  end
end
