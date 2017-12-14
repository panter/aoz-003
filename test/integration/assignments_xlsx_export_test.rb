require 'test_helper'

class AssignmentsXlsxExportTest < ActionDispatch::IntegrationTest
  def setup
    @superadmin = create :user
    login_as @superadmin
  end

  test 'xlsx file is downloadable' do
    10.times { create :assignment }
    get assignments_url(format: :xlsx)
    assert_equal Mime[:xlsx], response.content_type
  end

  test 'xlsx files columns and cells are correct' do
    assignment = create :assignment, period_start: 3.months.ago, period_end: 2.days.ago
    wb = get_xls_from_response(assignments_url(format: :xlsx))

    assert_xls_cols_equal(wb, 1, 0, 'id', 'Freiwillige/r', 'Klient/in', 'Start date', 'End date',
      'State', 'Created at', 'Updated at')

    assert_xls_cols_equal(wb, 2, 0, assignment.id, assignment.volunteer.contact.full_name,
      assignment.client.contact.full_name, assignment.period_start, assignment.period_end,
      I18n.t("simple_form.options.assignment.state.#{assignment.state}"))
    assert_equal assignment.created_at.to_date, wb.cell(2, 7).to_date
    assert_equal assignment.updated_at.to_date, wb.cell(2, 8).to_date

    assert_equal(
      assignment.updated_at.localtime.to_time.to_s.slice(0..-9),
      wb.cell(2, 8).to_time.to_s.slice(0..-9)
    )
    assert_equal(
      assignment.created_at.localtime.to_time.to_s.slice(0..-9),
      wb.cell(2, 7).to_time.to_s.slice(0..-9)
    )
  end

  test 'assignments xls export is not paginated' do
    30.times { create :assignment }
    wb = get_xls_from_response(assignments_url(format: :xlsx))
    assert_equal Assignment.count + 1, wb.last_row
  end
end
