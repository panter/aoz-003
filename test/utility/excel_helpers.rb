class ActiveSupport::TestCase
  def get_xls_from_response(url)
    get url
    assert response.successful?
    assert_equal Mime[:xlsx], response.content_type
    excel_file = Tempfile.new
    excel_file.write(response.body)
    excel_file.close
    Roo::Spreadsheet.open(excel_file.path, extension: 'xlsx')
  end

  def assert_xls_cols_equal(wb, row, offset, *columns)
    columns.each_with_index do |column, index|
      assert_equal column.to_s, wb.cell(row, index + 1 + offset).to_s
    end
  end

  def assert_xls_row_empty(wb, row, cols = 8)
    (1..cols).to_a.each { |column| assert_nil wb.cell(row, column) }
  end
end
