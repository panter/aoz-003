require 'application_system_test_case'

class CertificatesTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @volunteer = create(
      :volunteer, :with_assignment, state: 'resigned', user: create(:user_volunteer)
    )
    @assignment = @volunteer.assignments.first
    @hour = create :hour, volunteer: @volunteer, hourable: @assignment, hours: 2,
      minutes: 15
  end

  test 'volunteer user can not see create certificate button' do
    login_as @volunteer.user
    visit volunteer_path(@volunteer)
    assert page.has_no_link? 'Create certificate'
  end

  test 'Creating volunteer certificate form has right content prefilled' do
    group_offer = create :group_offer, volunteers: [@volunteer]
    group_offer.group_assignments.last.update(period_start: 2.years.ago)
    login_as @user
    visit volunteer_path(@volunteer)
    click_link 'Create certificate'
    assert page.has_text? 'New Certificate'
    assert page.has_field? 'Text body', text: 'Die **AOZ** ist ein Unternehmen der Stadt Zürich und'
    assert page.has_field? 'Hours', with: 2
    click_button 'Edit more fields'
    assert page.has_field? 'Assignment', checked: true
    assert page.has_field? 'Name', with: @volunteer.contact.full_name
    assert page.find_field('Street').value.include? @volunteer.contact.street
    assert page.find_field('City').value.include? @volunteer.contact.city
    assert page.find_field('Function').value.include? 'Förderung der sozialen und beruflichen Integ'
    assert page.find_field('Institution').value.include? '**AOZ** Zürich, Flüelastrasse 32, 8047'
    page.find_button('Create Certificate').click
    assert page.has_text? 'AOZ Zürich, Flüelastrasse 32, 8047'
    assert page.has_text? @volunteer.contact.full_name
    assert page.has_text? @volunteer.certificates.first.created_at.to_date.to_s
    assert page.has_text? @volunteer.min_assignment_date
    assert page.has_text? @volunteer.max_assignment_date
    assert page.has_link? 'Print'
  end

  test 'Updating certificate with custom values' do
    login_as @user
    visit new_volunteer_certificate_path(@volunteer)
    click_button 'Create Certificate'

    assert page.has_text? 'Show Certificate'
    click_link 'Edit Certificate'

    fill_in 'Text body', with: '**Bold** or not *bold*, that is this tests Question?<br>***both***'
    assert page.has_text? 'Edit Certificate'
    click_button 'Edit more fields'
    assert page.has_field? 'Assignment', checked: true
    fill_in 'Hours', with: 555
    fill_in 'Name', with: 'This bogus test name'
    fill_in 'Institution', with: 'The Testology Institute'
    page.find_button('Update Certificate').click
    assert page.has_text? '555'
    assert page.has_text? 'This bogus test name'
    assert page.has_text? 'The Testology Institute'
    assert page.has_text? 'Bold or not bold, that is this tests Question? both'
  end

  test 'volunteer that has only group offers can have certificate' do
    volunteer = create :volunteer
    create :group_offer, volunteers: [volunteer]
    volunteer.group_assignments.last.update(period_start: 2.months.ago)
    login_as @user

    visit volunteer_path(volunteer)
    assert page.has_link? 'Create certificate'
    click_link 'Create certificate'
    page.find_button('Create Certificate').click
    assert page.has_text? 'Die AOZ ist ein Unternehmen der Stadt Zürich'
  end
end
