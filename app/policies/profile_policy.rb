class ProfilePolicy < ApplicationPolicy
  attr_reader :user, :profile

  def initialize(user, profile)
    @user = user
    @profile = profile
  end

  delegate :superadmin?, to: :user

  def profile_owner?
    profile.user_id == user.id
  end

  def superadmin_or_profile_owner?
    superadmin? || profile_owner?
  end

  alias_method :show?,   :superadmin_or_profile_owner?
  alias_method :edit?,   :superadmin_or_profile_owner?
  alias_method :create?, :superadmin_or_profile_owner?
  alias_method :update?, :superadmin_or_profile_owner?

  alias_method :new?,    :profile_owner?
end
