class AssignmentPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      scope.where(creator_id: user.id) if department_manager?
      none
    end

    def seeking_clients
      return scope.seeking_clients_will_take_more if superadmin?
      return scope.seeking_clients if department_manager?
      none
    end
  end

  alias_method :index?,          :superadmin_or_department_manager?
  alias_method :show?,           :admin_or_department_manager_or_assignment_related?
  alias_method :edit?,           :admin_or_department_manager_or_assignment_related?
  alias_method :update?,         :admin_or_department_manager_or_assignment_related?
  alias_method :new?,            :superadmin_or_department_manager?
  alias_method :create?,         :superadmin_or_department_manager?
  alias_method :destroy?,        :superadmin?
  alias_method :find_volunteer?, :superadmin_or_department_manager?
  alias_method :find_client?,    :superadmin_or_department_manager?

  # credential policies
  alias_method :supervisor?,     :superadmin_or_department_manager?
end
