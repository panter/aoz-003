require 'test_helper'

class ContactPhoneTest < ActiveSupport::TestCase
  def setup
    @contact_phone = ContactPhone.new
  end

  test 'contact email validates presence of body' do
    refute @contact_phone.valid?
    @contact_phone.body = 'asdfasdfasdf'
    refute @contact_phone.valid?
    @contact_phone.body = '+41 44 78 22 20'
    assert @contact_phone.valid?
  end
end
