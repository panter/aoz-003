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
    user.superadmin? || volunteers_owns_profile
  end

  def edit?
    user.superadmin? || volunteers_owns_profile
  end

  def update?
    user.superadmin? || volunteers_owns_profile
  end

  def destroy?
    user && user.superadmin?
  end

  def supervisor_privileges?
    user && user.superadmin?
  end

  def supervisor?
    user.superadmin?
  end

  def seeking_clients?
    user.superadmin?
  end

  private

  def volunteers_owns_profile
    user.volunteer? && user.volunteer == volunteer
  end
end
