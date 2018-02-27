require 'test_helper'

class EventsXlsxExportTest < ActionDispatch::IntegrationTest
  def setup
    @superadmin = create :user
    login_as @superadmin

    @event_volunteer1 = create :event_volunteer
    @event_volunteer2 = create :event_volunteer
    @event_volunteer3 = create :event_volunteer

    event = create :event, creator: @superadmin, kind: :intro_course,
      title: 'Juch Besuchstag',
      event_volunteers: [@event_volunteer1, @event_volunteer2, @event_volunteer3]

    get event_url(event, format: :xlsx)
  end

  # FIXME
  # test 'xlsx file is downloadable' do
  #   assert_equal Mime[:xlsx], response.content_type
  # end

  # test 'xlsx files has the right columns' do

  #   wb = get_xls_from_response(event_url(format: :xlsx))
  #   assert_xls_cols_equal(wb, 1, 0, 'Titel', 'Juch Besuchstag')
  #   assert_xls_cols_equal(wb, 2, 0, 'Art', 'Einführungskurs')
  # end
end
