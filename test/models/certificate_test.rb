require 'test_helper'

class CertificateTest < ActiveSupport::TestCase
  def setup
    user = create :user
    @volunteer = create :volunteer
    client = create :client
    assignment = create :assignment, client: client, volunteer: @volunteer, creator: user
    create :hour, volunteer: @volunteer, hourable: assignment
    group_offer_category = create :group_offer_category
    group_offer = create :group_offer, volunteers: [@volunteer],
      group_offer_category: group_offer_category
    create :hour, volunteer: @volunteer, hourable: group_offer

    @volunteer.certificates = Certificate.new
  end

  test 'certificate is valid' do
    assert @volunteer.certificates.valid?
  end
end
