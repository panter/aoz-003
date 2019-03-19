require 'test_helper'

class EventsXlsxExportTest < ActionDispatch::IntegrationTest
  def setup
    @superadmin = create :user
    login_as @superadmin

    @event_volunteer = create :event_volunteer

    @event = create :event,
      creator: @superadmin,
      title: 'Juch Besuchstag',
      kind: :intro_course,
      department: create(:department),
      event_volunteers: [@event_volunteer]

    get event_url(@event, format: :xlsx)
  end

  test 'xlsx files has the right columns' do
    wb = get_xls_from_response(event_url(@event, format: :xlsx))
    assert_xls_cols_equal(wb, 1, 0, 'Titel', 'Juch Besuchstag')
    assert_xls_cols_equal(wb, 2, 0, 'Art', 'Einführungsveranstaltung')
    assert_xls_cols_equal(wb, 3, 0, 'Ort', @event.department.contact.last_name)
    assert_xls_cols_equal(wb, 4, 0, 'Startzeit', @event.start_time.strftime('%H:%M'))
    assert_xls_cols_equal(wb, 5, 0, 'Endzeit', @event.end_time.strftime('%H:%M'))
    assert_xls_cols_equal(wb, 6, 0, 'Datum', I18n.l(@event.date))
    assert_xls_cols_equal(wb, 7, 0, 'Beschreibung', @event.description)
    assert_xls_cols_equal(wb, 12, 0, 'Teilnehmeranzahl', @event.volunteers.count)
    assert_xls_cols_equal(wb, 15, 0, 'Vorname', 'Nachname', 'Mailadresse', 'Beginn als FW', 'Adresse', 'Telefon', 'Jahrgang')
    assert_xls_cols_equal(wb, 16, 0,
      @event_volunteer.volunteer.contact.first_name,
      @event_volunteer.volunteer.contact.last_name,
      @event_volunteer.volunteer.contact.primary_email,
      I18n.l(@event_volunteer.volunteer.accepted_at.to_date),
      @event_volunteer.volunteer.contact.full_address,
      @event_volunteer.volunteer.contact.primary_phone,
      @event_volunteer.volunteer.birth_year.year)
  end
end
