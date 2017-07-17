require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  def setup
    @contact = Contact.new
  end

  test 'requires only first name for profiles' do
    @contact.contactable_type = 'Profile'

    refute @contact.valid?
    assert_equal @contact.errors.keys, [:first_name]
  end

  test 'requires only last name for departments' do
    @contact.contactable_type = 'Department'

    refute @contact.valid?
    assert_equal @contact.errors.keys, [:last_name]
  end
end
