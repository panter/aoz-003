class ClientPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      resolve_owner if social_worker?
    end
  end

  alias_method :index?,             :superadmin_or_social_worker?
  alias_method :new?,               :superadmin_or_social_worker?
  alias_method :create?,            :superadmin_or_social_worker?

  alias_method :show?,              :superadmin_or_social_workers_record?
  alias_method :edit?,              :superadmin_or_social_workers_record?
  alias_method :update?,            :superadmin_or_social_workers_record?

  alias_method :destroy?,           :superadmin?
  alias_method :need_accompanying?, :superadmin_or_department_manager?
  alias_method :supervisor?,        :superadmin?
end
