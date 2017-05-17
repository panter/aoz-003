require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  def setup
    @contact = Contact.new
  end

  test 'contact validates name presence if contactable Department' do
    @contact.contactable_type = 'Department'
    refute @contact.valid?
    @contact.name = 'Name'
    assert @contact.valid?
    assert @contact.save!
  end
end
