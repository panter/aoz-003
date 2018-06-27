require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  def setup
    # client is by default accepted
    @client = create :client, :with_relatives, :with_language_skills
  end

  test 'client invalid with required attributes is valid' do
    assert @client.valid?
  end

  test 'client invalid with no required attributes is invalid' do
    client = Client.new
    refute client.valid?
  end

  test 'a client without assignment should show up in inactive' do
    result = Client.inactive
    assert_equal [@client], result.to_a
  end

  test 'a client with an active assignment should not show up in inactive' do
    create :assignment_active, client: @client
    result = Client.inactive
    assert_equal [], result.to_a
  end

  test 'a client with an inactive assignment should show up in inactive' do
    client = create :client
    create :assignment_inactive, client: client
    result = Client.inactive
    assert result.include? @client
    assert result.include? client
  end

  test 'contact relation is build automatically' do
    new_client = Client.new
    assert new_client.contact.present?
  end

  test 'records acceptance changes' do
    client = create :client

    refute_nil client.accepted_at
    assert_nil client.rejected_at
    assert_nil client.resigned_at

    client.update(acceptance: :rejected)

    refute_nil client.accepted_at
    refute_nil client.rejected_at
    assert_nil client.resigned_at

    client.update(acceptance: :resigned)

    refute_nil client.accepted_at
    refute_nil client.rejected_at
    refute_nil client.resigned_at
  end

  test 'a client with an inactive assigntment should be inactive' do
    create :assignment_inactive, client: @client
    assert @client.inactive?
  end

  test 'client with an active assigntment should be active' do
    create :assignment_active, client: @client
    assert @client.active?
  end

  test 'client inactive state' do
    @client.update acceptance: :rejected
    refute @client.accepted?
    refute @client.inactive?

    @client.update acceptance: :accepted
    assert @client.accepted?
    assert @client.inactive?

    assignment = create :assignment, client: @client, period_start: nil, period_end: nil
    assert @client.inactive?

    assignment.update period_start: 10.days.ago
    refute @client.inactive?

    assignment.update period_end: 5.days.ago
    assert @client.inactive?
  end

  test 'client active state' do
    @client.update acceptance: :rejected
    refute @client.accepted?
    refute @client.active?

    @client.update acceptance: :accepted
    assert @client.accepted?
    refute @client.active?

    assignment = create :assignment, client: @client, period_start: nil, period_end: nil
    refute @client.active?

    assignment.update period_start: 10.days.ago
    assert @client.active?

    assignment.update period_end: 5.days.ago
    assert_not @client.active?
  end

  test 'client is destroyable' do
    client = create :client
    assert client.destroyable?

    assignment = create :assignment, client: client
    refute client.destroyable?

    assignment.destroy
    refute_nil assignment.deleted_at
    refute client.destroyable?
  end

  test 'destroying a client' do
    client = create :client
    assert_nil client.deleted_at

    client.destroy!
    refute_nil client.reload.deleted_at

    client = create :client, :with_relatives
    assert_nil client.deleted_at

    client.destroy!
    refute_nil client.reload.deleted_at
    client.relatives.each do |relative|
      assert_nil relative.deleted_at
    end

    client = create :client
    assignment = create :assignment, client: client
    assignment_ids = client.assignments.pluck(:id).join(', ')
    message = "There are one or more assignment associated: #{assignment_ids}"
    exception = assert_raise Client::NotDestroyableError do
      client.destroy!
    end
    assert_equal message, exception.message

    assignment.destroy
    exception = assert_raise Client::NotDestroyableError do
      client.destroy!
    end
    assert_equal message, exception.message
  end
end
