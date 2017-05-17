require 'test_helper'

class ContactEmailTest < ActiveSupport::TestCase
  def setup
    @contact_email = ContactEmail.new
  end

  test 'contact email validates presence of body' do
    refute @contact_email .valid?
    @contact_email.body = 'asdfasdfasdf'
    refute @contact_email.valid?
    @contact_email.body = 'someone@anywhere.com'
    assert @contact_email.valid?
  end
end
