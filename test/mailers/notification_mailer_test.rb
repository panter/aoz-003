require 'test_helper'

class NotificationMailerest < ActionMailer::TestCase
  def setup
    @superadmin = create :superadmin
    @other_superadmin = create :superadmin
  end

  test 'termination_submitted assignment' do
    assignment = create :terminated_assignment, creator: @superadmin
    assignment.update!(termination_submitted_by: @other_superadmin, period_end_set_by: @superadmin)

    mailer = NotificationMailer.termination_submitted(assignment).deliver

    assert_includes mailer.to, @superadmin.email
    text = mailer.text_part.body.decoded
    html = mailer.html_part.body.decoded
    assert_match @other_superadmin.email, text
    assert_match @other_superadmin.email, html

    assert_match '/assignments/terminated_index', text
    assert_match '/assignments/terminated_index', html
  end

  test 'termination_submitted group_assignment' do
    group_assignment = create :terminated_group_assignment, creator: @superadmin
    group_assignment.update!(termination_submitted_by: @other_superadmin, period_end_set_by: @superadmin)

    mailer = NotificationMailer.termination_submitted(group_assignment).deliver

    assert_includes mailer.to, @superadmin.email
    text = mailer.text_part.body.decoded
    html = mailer.html_part.body.decoded
    assert_match @other_superadmin.email, text
    assert_match @other_superadmin.email, html

    assert_match '/group_assignments/terminated_index', text
    assert_match '/group_assignments/terminated_index', html
  end
end
