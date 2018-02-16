require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @department = create :department
    @department.contact.update(last_name: 'Event Department')
    login_as @user
    visit new_event_path
  end

  test 'new event form' do
    assert page.has_text? 'New Veranstaltung'
    select('Einführungsveranstaltung', from: 'Art')
    fill_in 'Titel', with: 'Titel asdf'
    select('Event Department', from: 'Standort')

    fill_in 'Beschreibung', with: 'Beschreibung asdf'
    click_button 'Create Veranstaltung'

    assert page.has_text? 'Titel asdf'
    assert page.has_text? 'Beschreibung asdf'
    assert page.has_text? 'Event Department'
  end
end
