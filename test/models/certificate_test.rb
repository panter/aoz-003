require 'test_helper'

class CertificateTest < ActiveSupport::TestCase
  test 'certificate is valid' do
    certificate = Certificate.new
    refute certificate.valid?
    error_msgs = { volunteer: ['must exist'], user: ['must exist'] }
    assert_equal error_msgs, certificate.errors.messages
    certificate.user = create :user
    refute certificate.valid?
    assert_equal error_msgs.except(:user), certificate.errors.messages
    certificate.volunteer = create :volunteer
    assert certificate.valid?
  end
end
