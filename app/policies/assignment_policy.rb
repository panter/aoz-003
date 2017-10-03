class AssignmentPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      all if superadmin?
    end
  end

  alias_method :index?,          :superadmin?
  alias_method :show?,           :admin_or_department_manager_or_volunteer_related?
  alias_method :edit?,           :admin_or_department_manager_or_volunteer_related?
  alias_method :update?,         :admin_or_department_manager_or_volunteer_related?
  alias_method :new?,            :superadmin_or_department_manager?
  alias_method :create?,         :superadmin_or_department_manager?
  alias_method :destroy?,        :superadmin?
  alias_method :find_volunteer?, :superadmin_or_department_manager?
  alias_method :find_client?,    :superadmin_or_department_manager?
  alias_method :supervisor?,     :superadmin?
end
