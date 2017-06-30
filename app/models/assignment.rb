class Assignment < ApplicationRecord
  belongs_to :client
  belongs_to :volunteer

  has_attached_file :agreement
  validates_attachment :agreement, content_type: { content_type: 'application/pdf' }

  def to_pdf
    pdf_html = ApplicationController.render(
      'assignments/show', layout: 'layouts/pdf', assigns: { assignment: self }
    )
    doc_pdf = WickedPdf.new.pdf_from_string(pdf_html, page_size: 'A4')

    pdf_path = Rails.root.join('tmp', "#{Date.current.iso8601}.pdf")
    File.open(pdf_path, 'wb') do |file|
      file << doc_pdf
    end

    self.agreement = File.open pdf_path

    #File.delete(pdf_path) if File.exist?(pdf_path)
  end
end
