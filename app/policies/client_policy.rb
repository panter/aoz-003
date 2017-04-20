class ClientPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.superadmin?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end

  def show?
    user.superadmin? || scope.user_id == user.id
  end

  def new?
    user.admin_or_superadmin? || user.social_worker?
  end

  def edit?
    user.superadmin? || scope.user_id == user.id
  end

  def create?
    user.admin_or_superadmin? || user.social_worker?
  end

  def update?
    user.superadmin? || scope.user_id == user.id
  end
end
