require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  def setup
    @contact = Contact.new
  end

  test 'Dont require first and lastname on profiles' do
    @contact.contactable_type = 'Profile'

    assert @contact.valid?
  end

  test 'Required fields for Clients' do
    @contact.contactable_type = 'Client'

    refute @contact.valid?
    assert_equal @contact.errors.keys, [:last_name, :first_name, :primary_phone, :street,
                                        :postal_code, :city]
  end

  test 'Required fields for Volunteers' do
    @contact.contactable_type = 'Volunteer'

    refute @contact.valid?
    assert_equal @contact.errors.keys, [:last_name, :first_name, :primary_email, :primary_phone,
                                        :street, :postal_code, :city]
  end

  test 'Required fields for external Volunteers' do
    volunteer = build :volunteer, external: true
    volunteer.contact = Contact.new
    refute volunteer.valid?
    assert_equal volunteer.contact.errors.keys, [:last_name, :first_name, :street, :postal_code,
                                                 :city]
  end

  test 'requires only last name for departments' do
    @contact.contactable_type = 'Department'

    refute @contact.valid?
    assert_equal @contact.errors.keys, [:last_name]
  end
end
