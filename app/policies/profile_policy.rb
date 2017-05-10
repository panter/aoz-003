class ProfilePolicy < ApplicationPolicy
  attr_reader :user, :profile

  def initialize(user, profile)
    @user = user
    @profile = profile
  end

  def show?
    @user.superadmin? || @profile.user_id == @user.id
  end

  def new?
    @profile.user_id == @user.id
  end

  def edit?
    @user.superadmin? || @profile.user_id == @user.id
  end

  def create?
    @user.superadmin? || @profile.user_id == @user.id
  end

  def update?
    @user.superadmin? || @profile.user_id == @user.id
  end
end
