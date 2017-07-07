class JournalPolicy < ApplicationPolicy
  attr_reader :user, :journal

  def initialize(user, journal)
    @user = user
    @journal = journal
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
    user.superadmin?
  end
end
