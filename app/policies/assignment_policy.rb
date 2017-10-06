class AssignmentPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      return scope.where(creator_id: user.id) if department_manager? || social_worker?
      none
    end
    alias :seeking_clients :resolve
  end

  # controller action policies
  alias_method :index?,          :superadmin_or_department_manager?
  alias_method :new?,            :superadmin_or_department_manager?
  alias_method :create?,         :superadmin_or_department_manager?
  alias_method :find_volunteer?, :superadmin_or_department_manager?
  alias_method :find_client?,    :superadmin_or_department_manager?

  alias_method :show?,   :admin_or_department_manager_or_assignment_related?
  alias_method :edit?,   :admin_or_department_manager_or_assignment_related?
  alias_method :update?, :admin_or_department_manager_or_assignment_related?

  alias_method :destroy?, :superadmin?

  # supplemental policies
  alias_method :supervisor?, :superadmin_or_department_manager?
end
