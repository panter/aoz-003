require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  def setup
    @department = Department.new
  end

  test 'department is saveable with user relation' do
    refute @department.valid?
    @department.contact = build :contact
    assert @department.valid?
    assert @department.save!
  end

  test 'department contact without name is invalid' do
  end
end
