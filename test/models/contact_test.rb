require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  def setup
    @contact = Contact.new
  end

  test 'Dont require first and lastname on profiles' do
    @contact.contactable_type = 'Profile'

    assert @contact.valid?
  end

  test 'Require primary_email, first and last name for Clients' do
    @contact.contactable_type = 'Client'

    refute @contact.valid?
    assert_equal @contact.errors.keys, [:last_name, :first_name, :primary_email]
  end

  test 'Require primary_email, first and last name for Volunteers' do
    @contact.contactable_type = 'Volunteer'

    refute @contact.valid?
    assert_equal @contact.errors.keys, [:last_name, :first_name, :primary_email]
  end

  test 'requires only last name for departments' do
    @contact.contactable_type = 'Department'

    refute @contact.valid?
    assert_equal @contact.errors.keys, [:last_name]
  end
end
