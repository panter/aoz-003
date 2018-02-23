require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  def setup
    @department = build :department
  end

  test 'department is valid' do
    assert @department.valid?
  end

  test 'contact relation is build automatically' do
    new_department = Department.new
    assert new_department.contact.present?
  end
end
