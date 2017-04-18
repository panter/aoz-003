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

  def update?
    user.superadmin? || client.user_id == user.id
  end

  def show?
    user.superadmin? || scope.user_id == user.id
  end

  def edit?
    user.superadmin? || client.user_id == user.id
  end

  def create?
    user.admin_superadmin? || user.social_worker?
  end

  def new?
    user.admin_superadmin? || user.social_worker?
  end
end
