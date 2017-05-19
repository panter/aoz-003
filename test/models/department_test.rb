require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  def setup
    @department = create :department
  end

  test 'department is valid' do
    assert @department.valid?
  end
end
