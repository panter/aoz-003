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

  test 'no duplicate assignment' do
    user = create :user
    volunteer = create :volunteer
    client = create :client
    assignment = create :assignment, client: client, volunteer: volunteer, creator: user

    assignment_dup = assignment.dup
    assignment_dup.save

    refute assignment_dup.persisted?
    assert_equal ['Die Begleitung existiert bereits.'], assignment_dup.errors[:client_id]
  end
end
