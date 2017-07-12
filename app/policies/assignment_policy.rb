class AssignmentPolicy < ApplicationPolicy
  attr_reader :user, :assignment

  def initialize(user, assignment)
    @user = user
    @assignment = assignment
  end

  def index?
    user.superadmin?
  end

  def show?
    user.superadmin?
  end

  def new?
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

  def find_volunteer?
    user.superadmin?
  end

  def find_client?
    user.superadmin?
  end
end
