class DepartmentPolicy < ApplicationPolicy
  attr_reader :user, :department

  def initialize(user, department)
    @user = user
    @department = department
  end

  def new?
    @user.superadmin?
  end

  def create?
    @user.superadmin?
  end

  def destroy?
    @user.superadmin?
  end
end
