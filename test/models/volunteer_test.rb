require 'test_helper'

class VolunteerTest < ActiveSupport::TestCase
  def setup
    @volunteer = create :volunteer
  end

  test 'valid factory' do
    assert @volunteer.valid?
  end

  test 'contact relation is built automaticly' do
    new_volunteer = Volunteer.new
    assert new_volunteer.contact.present?
  end

  test 'external field is default false' do
    assert_equal false, @volunteer.external
  end

  test 'external volunteer can have no user' do
    external_volunteer = create :volunteer, external: true
    volunteer_user = create :user_volunteer
    external_volunteer.user = volunteer_user
    refute external_volunteer.valid?
    assert_equal ['must be blank'], external_volunteer.errors.messages[:user]
    external_volunteer.external = false
    assert external_volunteer.valid?
  end

  test 'a internal volunteer turned into a external, having a user, user gets softdeleted' do
    volunteer_user = create :user_volunteer
    volunteer = create :volunteer, state: 'accepted', external: false, user: volunteer_user
    assert volunteer.valid?
    volunteer.update external: true
    volunteer.save
    refute volunteer_user.deleted_at.nil?
    assert volunteer.user_id.nil?
  end
end
