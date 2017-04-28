require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase
  context 'associations' do
    should belong_to(:client)
  end
end
