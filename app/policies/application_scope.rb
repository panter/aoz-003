module ApplicationScope
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    delegate :superadmin?, to: :user
    delegate :department_manager?, to: :user
    delegate :social_worker?, to: :user
    delegate :volunteer?, to: :user

    delegate :all, to: :scope

    def resolve
      scope
    end

    def resolve_owner
      scope.where(user: user)
    end

    def resolve_all_to_superadmin
      all if superadmin?
    end

    def resolve_superadmin_or_owner
      return all if superadmin?
      resolve_owner
    end

    def resolve_superadmin_or_volunteer_owns
      return all if superadmin?
      resolve_owner if volunteer?
    end

    def resolve_superadmin_or_social_worker_owns
      return all if superadmin?
      resolve_owner if social_worker?
    end
  end
end
