class ActiveSupport::TestCase
  def load_pdf(data)
    raise 'PDFs can only be loaded with the rack driver!' unless Capybara.current_driver == :rack

    PDF::Reader.new(StringIO.new(data))
  end
end
