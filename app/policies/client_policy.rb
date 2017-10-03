class ClientPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      resolve_owner if department_manager?
    end
  end

  alias_method :index?,             :superadmin_or_department_manager?
  alias_method :new?,               :superadmin_or_department_manager?
  alias_method :create?,            :superadmin_or_department_manager?

  alias_method :show?,              :superadmin_or_social_workers_record?
  alias_method :edit?,              :superadmin_or_social_workers_record?
  alias_method :update?,            :superadmin_or_social_workers_record?

  alias_method :destroy?,           :superadmin?
  alias_method :need_accompanying?, :superadmin_or_department_manager?

  # suplementary policies
  alias_method :supervisor?, :superadmin?
  alias_method :journals?,   :superadmin?
  alias_method :comments?,   :superadmin?
end
