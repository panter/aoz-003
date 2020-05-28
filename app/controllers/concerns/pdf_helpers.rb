module PdfHelpers
  def pdf_file_name(record)
    date = record.try(:pdf_updated_at) || record.updated_at
    filename = "#{record.model_name.human}-#{record.id}"
    date ? "#{filename}-#{date.strftime '%F'}.pdf" : "#{filename}.pdf"
  end

  def render_to_pdf(action = "#{action_name}.html", options = {})
    html = render_to_string({ action: action }.merge(options))
    WickedPdf.new.pdf_from_string(html, options)
  end

  def render_pdf_attachment(record)
    unless record.pdf.attached?
      raise ActiveRecord::RecordNotFound, 'PDF attachment does not exist'
    end

    send_data record.pdf.download,
              disposition: 'inline',
              filename: pdf_file_name(record)
  end

  # currently only used for assignments
  def save_with_pdf(record, action = 'show.html', options = {})
    { layout: 'assignments.pdf.slim', zoom: 1.15,
      dpi: 600, margin: { top: 0, bottom: 10, left: 0, right: 14 } }.each do |k, v|
      next if options.key?(k)

      options[k] = v
    end

    if record.generate_pdf
      record.pdf.attach(
        io: StringIO.new(render_to_pdf(action, options)),
        filename: pdf_file_name(record),
        content_type: 'application/pdf'
      )
    end
    record.save
  end
end
