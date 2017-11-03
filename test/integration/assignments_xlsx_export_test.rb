require 'test_helper'

class AssignmentsXlsxExportTest < ActionDispatch::IntegrationTest
  def setup
    @superadmin = create :user
    login_as @superadmin
  end

  test 'xlsx file is downloadable' do
    10.times { create :assignment }
    get assignments_url(format: :xlsx)
    assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      response.content_type
  end

  test 'xlsx files columns and cells are correct' do
    assignment = create :assignment, period_start: 3.months.ago, period_end: 2.days.ago
    get assignments_url(format: :xlsx)
    excel_file = Tempfile.new
    excel_file.write(response.body)
    excel_file.close
    wb = Roo::Spreadsheet.open(excel_file.path, extension: 'xlsx')

    assert_equal 'id',            wb.cell(1, 1)
    assert_equal 'Klient/in',     wb.cell(1, 2)
    assert_equal 'Freiwillige/r', wb.cell(1, 3)
    assert_equal 'Start date',    wb.cell(1, 4)
    assert_equal 'End date',      wb.cell(1, 5)
    assert_equal 'State',         wb.cell(1, 6)
    assert_equal 'Created at',    wb.cell(1, 7)
    assert_equal 'Updated at',    wb.cell(1, 8)

    assert_equal assignment.id,                           wb.cell(2, 1)
    assert_equal assignment.client.contact.full_name,     wb.cell(2, 2)
    assert_equal assignment.volunteer.contact.full_name,  wb.cell(2, 3)
    assert_equal assignment.period_start,                 wb.cell(2, 4)
    assert_equal assignment.period_end,                   wb.cell(2, 5)
    assert_equal I18n.t("simple_form.options.assignment.state.#{assignment.state}"), wb.cell(2, 6)
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
    get assignments_url(format: :xlsx)
    excel_file = Tempfile.new
    excel_file.write(response.body)
    excel_file.close
    wb = Roo::Spreadsheet.open(excel_file.path, extension: 'xlsx')
    assert_equal Assignment.count + 1, wb.last_row
  end
end
