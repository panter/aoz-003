require 'test_helper'

class VolunteerTest < ActiveSupport::TestCase
  def setup
    @volunteer = create :volunteer
  end

  test 'valid factory' do
    assert @volunteer.valid?
  end

  test 'contact relation is built automatically' do
    new_volunteer = Volunteer.new
    assert new_volunteer.contact.present?
  end

  test 'external field is default false' do
    assert_equal false, @volunteer.external
  end

  test 'external volunteer can have no user' do
    external_volunteer = create :volunteer_external
    volunteer_user = create :user_volunteer
    external_volunteer.user = volunteer_user
    assert external_volunteer.invalid?
    assert_equal ['darf nicht ausgefüllt werden'], external_volunteer.errors.messages[:user]
    external_volunteer.external = false
    assert external_volunteer.valid?
  end

  test 'an internal volunteer turned into a external, having a user, user gets softdeleted' do
    volunteer = create :volunteer_with_user, external: false
    assert volunteer.valid?
    volunteer.update(external: true)
    assert volunteer.user.deleted?
  end

  test 'an external volunteer used to be internal with user turned back internal gets back user' do
    volunteer = create :volunteer_with_user, external: false
    volunteer.update(external: true)
    volunteer.reload
    volunteer.update(external: false)
    refute volunteer.user.deleted?
  end

  test 'when an internal volunteer gets terminated will be marked as resigned' do
    volunteer = create :volunteer_with_user, external: false
    assert volunteer.valid?
    volunteer.terminate!
    volunteer.reload
    assert volunteer.resigned?
    refute volunteer.active?
    refute volunteer.user.present?
  end

  test 'terminate_volunteer_without_user' do
    volunteer = create :volunteer

    assert_nil volunteer.user

    volunteer.terminate!

    assert volunteer.resigned?
  end

  test 'records acceptance changes' do
    volunteer = create :volunteer, acceptance: :undecided

    refute_nil volunteer.undecided_at
    assert_nil volunteer.invited_at
    assert_nil volunteer.accepted_at
    assert_nil volunteer.rejected_at
    assert_nil volunteer.resigned_at

    volunteer.update(acceptance: :accepted)

    refute_nil volunteer.undecided_at
    assert_nil volunteer.invited_at
    refute_nil volunteer.accepted_at
    assert_nil volunteer.rejected_at
    assert_nil volunteer.resigned_at

    volunteer.update(acceptance: :rejected)

    refute_nil volunteer.undecided_at
    assert_nil volunteer.invited_at
    refute_nil volunteer.accepted_at
    refute_nil volunteer.rejected_at
    assert_nil volunteer.resigned_at
  end
end
