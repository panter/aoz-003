class ActiveSupport::TestCase
  def load_pdf(data)
    PDF::Reader.new(StringIO.new(data))
  end
end
