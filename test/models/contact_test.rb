require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  def setup
    @contact = Contact.new
  end

  test 'email validation' do
    contact = build :contact, contactable: build(:volunteer)
    contact.primary_email = nil

    refute contact.valid?
    assert_includes contact.errors.keys, :primary_email

    contact.primary_email = @contact.primary_email

    refute contact.valid?
    assert_includes contact.errors.keys, :primary_email

    contact.primary_email = FFaker::Internet.unique.email

    assert contact.valid?
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
    volunteer = build :volunteer_external
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

  test 'update_first_or_lastname_changes_full_name_attribute' do
    volunteer = create :volunteer
    full_name_before = volunteer.contact.full_name
    volunteer.contact.update(first_name: 'aaaaaaaa')
    assert_not_equal full_name_before, volunteer.contact.full_name
    full_name_before = volunteer.contact.full_name
    volunteer.contact.update(last_name: 'zzzzzzzzz')
    assert_not_equal full_name_before, volunteer.contact.full_name
  end

  test 'full_name_not_filled_on_department' do
    department = Department.new
    department.contact.last_name = 'testing department'
    department.save
    assert department.contact.full_name.nil?
    department.contact.update(last_name: 'new name')
    assert department.contact.full_name.nil?
  end
end
