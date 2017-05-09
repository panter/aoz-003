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

  def initialize(user, client)
    @user = user
    @client = client
  end

  def index?
    user.superadmin? || user.social_worker?
  end

  def show?
    user.admin_or_superadmin? || @client.user_id == user.id
  end

  def new?
    user.staff?
  end

  def edit?
    user.superadmin? || @client.user_id == user.id
  end

  def create?
    user.staff?
  end

  def update?
    user.superadmin? || @client.user_id == user.id
  end

  def destroy?
    user.admin_or_superadmin?
  end
end
