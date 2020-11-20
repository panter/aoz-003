module XlsHelper
  AXLSX_COL_ALPHA_INDEX = ('A'..'Z').to_a +
    ('A'..'Z').to_a.map { |letter| "A#{letter}" } +
    ('A'..'Z').to_a.map { |letter| "B#{letter}" }

  # rubocop:disable Metrics/MethodLength
  def axlsx_locals(work_book, params)
    {
      wb: work_book,
      std_style: work_book.styles.add_style(
        alignment: { wrap_text: true, horizontal: :left, vertical: :top },
        width: :auto_fit
      ),
      date_style: work_book.styles.add_style(
        alignment: { horizontal: :left, vertical: :top },
        format_code: 'dd.mm.yyyy',
        width: :auto_fit
      ),
      time_style: work_book.styles.add_style(
        alignment: { horizontal: :left, vertical: :top },
        format_code: 'hh:mm',
        width: :auto_fit
      ),
      date_time_style: work_book.styles.add_style(
        alignment: { horizontal: :left, vertical: :top },
        format_code: 'dd.mm.yyyy hh:mm',
        width: :auto_fit
      ),
      header_style: work_book.styles.add_style(
        bg_color: 'FFDFDEDF',
        b: true,
        alignment: { horizontal: :center, vertical: :center },
        border: { color: '00', edges: [:bottom], style: :thin },
        width: :auto_fit
      ),
      wrapped_style: work_book.styles.add_style(
        alignment: { wrap_text: true, horizontal: :left, vertical: :top }
      ),
      zeit: Time.zone.now,
      col_alpha_indexes: AXLSX_COL_ALPHA_INDEX
    }.merge(params)
  end
  # rubocop:enable Metrics/MethodLength

  def axlsx_autofilter(sheet, columns, rows_collection, first_col: 'A', first_row: 1)
    last_cell = "#{AXLSX_COL_ALPHA_INDEX[columns.size - 1]}#{rows_collection.size + 1}"
    sheet.auto_filter = "#{first_col}#{first_row}:#{last_cell}"
    sheet.sheet_view.pane do |pane|
      pane.top_left_cell = "#{first_col}#{first_row + 1}"
      pane.state = :frozen_split
      pane.y_split = 1
      pane.x_split = 0
      pane.active_pane = :bottom_right
    end
  end
end
