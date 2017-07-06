class VolunteerEmailPolicy < ApplicationPolicy
  attr_reader :user, :volunteer_email

  def initialize(user, volunteer_email)
    @user = user
    @volunteer_email = volunteer_email
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

  def create?
    user.superadmin?
  end

  def update?
    user.superadmin?
  end

  def destroy?
    user.superadmin?
  end

  def supervisor_privileges?
    user.superadmin?
  end
end
