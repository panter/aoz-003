require 'test_helper'

class ReminderMailingTest < ActiveSupport::TestCase
  test 'reminder_mailing_has_users_through' do
    volunteer_user = create :volunteer_with_user
  end
end
