class VolunteerPolicy < ApplicationPolicy
  attr_reader :user, :volunteer

  def initialize(user, volunteer)
    @user = user
    @volunteer = volunteer
  end

  def new?
    user.superadmin?
  end

  def create?
    user.superadmin?
  end

  def index?
    user.superadmin?
  end

  def show?
    user.superadmin?
  end

  def edit?
    user.superadmin?
  end

  def update?
    user.superadmin?
  end

  def destroy?
    user && user.superadmin?
  end
end
