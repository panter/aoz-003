require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @department = create :department
    @department.contact.update(last_name: 'Event Department')
    @event = create :event, department: @department
    @volunteer1 = create :volunteer_with_user
    login_as @user
  end

  test 'new event form' do
    visit new_event_path
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

  test 'when creating a new event, it is not possible to add volunteers' do
    visit new_event_path
    assert page.has_text? 'New Veranstaltung'
    refute page.has_text? 'Neue Teilnehmende hinzufügen'
    refute page.has_select? 'event_volunteer_volunteer_id'
  end

  test 'add volunteers to an existing event' do
    visit event_path(@event)

    assert page.has_text? 'Neue Teilnehmende hinzufügen'
    select(@volunteer1, from: 'event_volunteer_volunteer_id')
    click_button 'Teilnehmer/in hinzufügen'
    visit current_url

    within '.event-volunteers-table' do
      assert page.has_text? @volunteer1.full_name
    end
  end

  test 'removing a volunteer from an existing event' do
    @volunteer2 = create :volunteer_with_user
    visit event_path(@event)

    # adding first volunteer to the event
    select(@volunteer1, from: 'event_volunteer_volunteer_id')
    click_button 'Teilnehmer/in hinzufügen'
    visit current_url
    within '.event-volunteers-table' do
      assert page.has_text? @volunteer1.full_name
      refute page.has_text? @volunteer2.full_name
    end

    # adding second volunteer to the event
    select(@volunteer2, from: 'event_volunteer_volunteer_id')
    click_button 'Teilnehmer/in hinzufügen'
    visit current_url
    within '.event-volunteers-table' do
      assert page.has_text? @volunteer1.full_name
      assert page.has_text? @volunteer2.full_name
      # removing the first volunteer from the event
      page.find_all('a', text: 'Löschen').first.click
    end

    visit current_url

    within '.event-volunteers-table' do
      refute page.has_text? @volunteer1.full_name
      assert page.has_text? @volunteer2.full_name
    end
  end

  test 'superadmin can only see volunteers past events on its profile' do
    @event_volunteer = create :event_volunteer
    @event.update(event_volunteers: [@event_volunteer], date: 7.days.ago)

    visit volunteer_path(@event_volunteer.volunteer)
    click_button 'Veranstaltungen'

    within '.volunteer-events-table' do
      assert page.has_text? @event.title
      assert page.has_text? 'Einführungsveranstaltung'
      assert page.has_text? 'Event Department'
      assert page.has_text? @event.end_time.strftime('%H:%M')
      assert page.has_text? @event.start_time.strftime('%H:%M')
      assert page.has_text? @event.date.strftime('%Y-%m-%d')
      assert page.has_link? 'Show'
    end
  end

  test 'future events are not shown on a volunteers profile' do
    @event_volunteer = create :event_volunteer
    @event.update(event_volunteers: [@event_volunteer], date: 7.days.from_now)

    visit volunteer_path(@event_volunteer.volunteer)
    refute page.has_button? 'Veranstaltungen'
  end

  test 'volunteer does not see own events on its profile' do
    @event_volunteer = create :event_volunteer
    @event.update(event_volunteers: [@event_volunteer])

    login_as @event_volunteer
    visit volunteer_path(@event_volunteer.volunteer)
    refute page.has_button? 'Veranstaltungen'
  end

  test 'event pagination' do
    really_destroy_with_deleted(Event)
    (1..20).to_a.map do
      event = create :event
      event.update(title: 'second_page')
      event
    end
    20.times do
      create :event
    end
    visit events_path
    first(:link, '2').click
    visit current_url

    assert page.has_css? '.pagination'
    Event.order('date desc').paginate(page: 2).each do |event|
      assert page.has_text? "#{event.title}"
    end
  end
end
