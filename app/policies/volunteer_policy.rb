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
    user.superadmin? || (user.volunteer? && user.volunteer.id == volunteer.id)
  end

  def edit?
    user.superadmin? || (user.volunteer? && user.volunteer.id == volunteer.id)
  end

  def update?
    user.superadmin? || (user.volunteer? && user.volunteer.id == volunteer.id)
  end

  def destroy?
    user && user.superadmin?
  end
end
