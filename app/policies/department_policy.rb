class DepartmentPolicy < ApplicationPolicy
  attr_reader :user, :department

  def initialize(user, department)
    @user = user
    @department = department
  end

  def new?
    @user.superadmin_or_department_manager?
  end

  def edit?
    @user.superadmin_or_department_manager?
  end

  def create?
    @user.superadmin_or_department_manager?
  end

  def update?
    @user.superadmin_or_department_manager?
  end

  def destroy?
    @user.superadmin_or_department_manager?
  end
end
