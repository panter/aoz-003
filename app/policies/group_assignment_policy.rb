class GroupAssignmentPolicy < ApplicationPolicy
  alias_method :index?,  :admin_or_department_manager_or_volunteer_related?
  alias_method :update?, :admin_or_department_manager_or_volunteer_related?
  alias_method :show?,   :admin_or_department_manager_or_volunteer_related?
  alias_method :update_submitted_at?, :admin_or_department_manager_or_volunteer_related?
  alias_method :last_submitted_hours_and_feedbacks?,
    :admin_or_department_manager_or_volunteer_related?

  alias_method :edit?,          :superadmin_or_department_manager?
  alias_method :update?,        :superadmin_or_department_manager?
  alias_method :set_end_today?, :superadmin_or_department_manager?

  alias_method :terminate?,     :superadmin_or_department_manager?
end
