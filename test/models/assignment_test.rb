require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
  def setup
    @assignment = create :assignment
  end

  test 'assignment with required attributes is valid' do
    assert @assignment.valid?
  end

  test 'assignment with no required attributes is invalid' do
    assignment = Assignment.new
    refute assignment.valid?
  end
end
