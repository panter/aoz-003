class ProfilePolicy < ApplicationPolicy
  attr_reader :user, :profile

  def initialize(user, profile)
    @user = user
    @profile = profile
  end

  def update?
    @profile.user_id == @user.id
  end

  def show?
    @user.admin_or_superadmin? || @profile.user_id == @user.id
  end

  def create?
    @profile.user_id == @user.id
  end

  def edit?
    @profile.user_id == @user.id
  end

  def new?
    @profile.user_id == @user.id
  end

  def edit?
    @profile.user_id == @user.id
  end
end
