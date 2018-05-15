module PdfHelpers
  def pdf_file_name(record)
    date = record.try(:pdf_updated_at) || record.updated_at
    "#{record.model_name.human}-#{record.id}-#{date.strftime '%F'}.pdf"
  end

  def render_to_pdf(action = "#{action_name}.html")
    html = render_to_string(action: action, layout: WickedPdf.config[:layout])
    WickedPdf.new.pdf_from_string(html)
  end

  def render_pdf_attachment(record)
    unless record.pdf.exists?
      raise ActiveRecord::RecordNotFound, 'PDF attachment does not exist'
    end

    send_file record.pdf.path,
      disposition: 'inline',
      filename: pdf_file_name(record)
  end

  def save_with_pdf(record, action = 'show.html')
    record.pdf = StringIO.new(render_to_pdf(action)) if record.generate_pdf
    record.save
  end
end
