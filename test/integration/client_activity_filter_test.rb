require 'test_helper'

class ClientActivityFilterTest < ActionDispatch::IntegrationTest
  def setup
    @superadmin = create :user
    @client_accepted = create :client, acceptance: 'accepted'
    create :assignment_active, client: @client_accepted
    @client_rejected = create :client, acceptance: 'rejected'
    create :assignment_active, client: @client_rejected
    @client_resigned = create :client, acceptance: 'resigned'
    create :assignment_active, client: @client_resigned
    login_as @superadmin
  end

  test 'client_tandem_active_filter_returns_accepted_active_client' do
    get clients_path(q: { active_eq: 'true' })
    assert response.body.include? @client_accepted.contact.full_name
    refute response.body.include? @client_rejected.contact.full_name
    refute response.body.include? @client_resigned.contact.full_name
  end

  test 'client_tandem_inactive_filter_returns_accepted_inactive_client' do
    get clients_path(q: { active_eq: 'false' })
    refute response.body.include? @client_accepted.contact.full_name
    refute response.body.include? @client_rejected.contact.full_name
    refute response.body.include? @client_resigned.contact.full_name
  end

  test 'client_acceptance_tandem_filters_work_together' do
    get clients_path(q: { acceptance_eq: '0', active_eq: 'true' })
    assert response.body.include? @client_accepted.contact.full_name
    refute response.body.include? @client_rejected.contact.full_name
    refute response.body.include? @client_resigned.contact.full_name

    get clients_path(q: { acceptance_eq: '0', active_eq: 'false' })
    refute response.body.include? @client_accepted.contact.full_name
    refute response.body.include? @client_rejected.contact.full_name
    refute response.body.include? @client_resigned.contact.full_name

    get clients_path(q: { acceptance_eq: '1', active_eq: 'true' })
    refute response.body.include? @client_accepted.contact.full_name
    refute response.body.include? @client_rejected.contact.full_name
    refute response.body.include? @client_resigned.contact.full_name

    get clients_path(q: { acceptance_eq: '1', active_eq: 'false' })
    refute response.body.include? @client_accepted.contact.full_name
    refute response.body.include? @client_rejected.contact.full_name
    refute response.body.include? @client_resigned.contact.full_name

    get clients_path(q: { acceptance_eq: '2', active_eq: 'true' })
    refute response.body.include? @client_accepted.contact.full_name
    refute response.body.include? @client_rejected.contact.full_name
    refute response.body.include? @client_resigned.contact.full_name

    get clients_path(q: { acceptance_eq: '2', active_eq: 'false' })
    refute response.body.include? @client_accepted.contact.full_name
    refute response.body.include? @client_rejected.contact.full_name
    refute response.body.include? @client_resigned.contact.full_name
  end
end
