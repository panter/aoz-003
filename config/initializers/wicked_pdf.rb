# WickedPDF Global Configuration
#
# Use this to set up shared configuration options for your entire application.
# Any of the configuration options shown here can also be applied to single
# models by passing arguments to the `render :pdf` call.
#
# To learn more, check out the README:
#
# https://github.com/mileszs/wicked_pdf/blob/master/README.md

WickedPdf.config = {
  layout: 'pdf.html',
  encoding: 'UTF-8',
  page_size: 'A4',
  print_media_type: true,
  no_background: true
}
