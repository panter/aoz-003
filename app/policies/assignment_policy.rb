class AssignmentPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :assignment

    def initialize(user, assignment)
      @user = user
      @assignment = assignment
    end

    def resolve
      assignment.all if user.superadmin?
    end
  end

  attr_reader :user, :assignment

  def initialize(user, assignment)
    @user = user
    @assignment = assignment
  end

  delegate :superadmin?, to: :user

  alias_method :index?, :superadmin?
  alias_method :show?, :superadmin?
  alias_method :new?, :superadmin?
  alias_method :edit?, :superadmin?
  alias_method :create?, :superadmin?
  alias_method :update?, :superadmin?
  alias_method :destroy?, :superadmin?
  alias_method :find_volunteer?, :superadmin?
  alias_method :find_client?, :superadmin?
end
