require 'test_helper'

class CertificateTest < ActiveSupport::TestCase
  test 'certificate is valid' do
    certificate = Certificate.new
    refute certificate.valid?
    error_msgs = { volunteer: ['muss ausgefüllt werden'], user: ['muss ausgefüllt werden'] }
    assert_equal error_msgs, certificate.errors.messages
    certificate.user = create :user
    certificate.volunteer = create :volunteer
    assert certificate.valid?
  end

  test 'no duplicates in collection_for_additional_kinds' do
    user = create :user
    volunteer = create :volunteer, :with_assignment

    certificate = Certificate.new(user: user, volunteer: volunteer)
    certificate.build_values

    tandem = ["Tandem", 0]

    assert certificate.assignment_kinds['done'].include?(tandem)
    assert certificate.assignment_kinds['available'].include?(tandem)

    refute certificate.collection_for_additional_kinds.include?(tandem)
  end
end
