class VolunteerPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      seeking_clients if department_manager?
    end

    def seeking_clients
      return scope.seeking_clients_will_take_more if superadmin?
      scope.seeking_clients if department_manager?
    end
  end

  alias_method :index?,           :superadmin_or_department_manager?
  alias_method :index_xls?,       :superadmin?
  alias_method :new?,             :superadmin_or_department_manager?
  alias_method :create?,          :superadmin_or_department_manager?
  alias_method :destroy?,         :superadmin?
  alias_method :seeking_clients?, :superadmin_or_department_manager?

  alias_method :show?,   :admin_or_department_manager_or_volunteer_related?
  alias_method :edit?,   :admin_or_department_manager_or_volunteer_related?
  alias_method :update?, :admin_or_department_manager_or_volunteer_related?

  # suplementary policies
  alias_method :can_manage?, :superadmin?
  alias_method :acceptance?, :superadmin?
  alias_method :checklist?,  :superadmin?
end
