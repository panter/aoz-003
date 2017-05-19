require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  def setup
    @department = create :department
  end

  test 'department is valid' do
    assert @department.valid?
    @department.contact.name = ''
    refute @department.valid?
  end
end
