class AssignmentPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      return scope.where(creator_id: user.id) if department_manager?
      none
    end
  end

  # controller action policies
  alias_method :index?,                :superadmin_or_department_manager?
  alias_method :terminated_index?,     :superadmin_or_department_manager?
  alias_method :volunteer_search?,     :superadmin_or_department_manager?
  alias_method :client_search?,        :superadmin_or_department_manager?
  alias_method :new?,                  :superadmin_or_department_manager?
  alias_method :create?,               :superadmin_or_department_manager?
  alias_method :find_client?,          :superadmin_or_department_manager?

  alias_method :show?,
    :superadmin_or_department_manager_creation_or_volunteer_related?
  alias_method :edit?,
    :superadmin_or_department_manager_creation?
  alias_method :update?,
    :superadmin_or_department_manager_creation?
  alias_method :terminate?,
    :superadmin_or_department_manager_creation?
  alias_method :update_terminated_at?,
    :superadmin_or_department_manager_creation?
  alias_method :verify_termination?,
    :superadmin?

  alias_method :update_submitted_at?,
    :superadmin_or_department_manager_creation_or_volunteer_related?
  alias_method :last_submitted_hours_and_feedbacks?,
    :superadmin_or_department_manager_creation_or_volunteer_related?
  alias_method :hours_and_feedbacks_submitted?,
   :superadmin_or_department_manager_or_volunteer?
end
