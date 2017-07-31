require 'test_helper'

class VolunteerApplicationPolicyTest < PolicyAssertions::Test
  test 'Anyone gets granted' do
    assert_permit(
      nil, :volunteer_application, 'new?', 'create?', 'thanks?'
    )
  end
end
