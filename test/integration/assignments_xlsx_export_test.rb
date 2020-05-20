require 'test_helper'

class AssignmentsXlsxExportTest < ActionDispatch::IntegrationTest
  def setup
    @superadmin = create :user
    login_as @superadmin
  end

  test 'xlsx files columns and cells are correct' do
    assignment = create :assignment, period_start: 3.months.ago, period_end: nil
    wb = get_xls_from_response(assignments_url(format: :xlsx))

    assert_xls_cols_equal(wb, 1, 0, 'Status', 'Freiwillige/r', 'Freiwillige/r Mailadresse',
                          'Klient/in', 'Einsatzbeginn', 'Einsatzende', 'Erstellt am', 'Aktualisiert am')

    assert_xls_cols_equal(wb, 2, 0, 'Aktiv',
                          assignment.volunteer.contact.full_name, assignment.volunteer.contact.primary_email,
                          assignment.client.contact.full_name, assignment.period_start, assignment.period_end)
    assert_equal assignment.created_at.to_date, wb.cell(2, 7)
    assert_equal assignment.updated_at.to_date, wb.cell(2, 8)

    assert_equal(
      assignment.updated_at.to_date.to_s.slice(0..-8),
      wb.cell(2, 8).to_s.slice(0..-8)
    )
    assert_equal(
      assignment.created_at.to_date.to_s.slice(0..-8),
      wb.cell(2, 7).to_s.slice(0..-8)
    )
  end

  test 'assignments xls export is not paginated' do
    30.times { create :assignment }
    wb = get_xls_from_response(assignments_url(format: :xlsx))
    assert_equal Assignment.count + 1, wb.last_row
  end
end
