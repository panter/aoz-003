require 'test_helper'

class CertificateTest < ActiveSupport::TestCase
  test 'certificate is valid' do
    certificate = Certificate.new
    refute certificate.valid?
    error_msgs = { volunteer: ['must exist'], user: ['must exist'] }
    assert_equal error_msgs, certificate.errors.messages
    certificate.user = create :user
    certificate.volunteer = create :volunteer_with_user
    assert certificate.valid?
  end
end
