class DepartmentPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :department
    def initialize(user, department)
      @user = user
      @department = department
    end

    def resolve
      if @user.superadmin?
        @department.all
      else
        @department.where(user: @user)
      end
    end
  end

  def initialize(user, department)
    @user = user
    @department = department
  end

  def index?
    @user.superadmin?
  end

  def show?
    @user.superadmin_or_department_manager?
  end

  def new?
    @user.superadmin?
  end

  def edit?
    @user.superadmin?
  end

  def create?
    @user.superadmin?
  end

  def update?
    @user.superadmin?
  end

  def destroy?
    @user.superadmin?
  end
end
