class GroupAssignmentPolicy < ApplicationPolicy
  alias_method :update?, :admin_or_department_manager_or_volunteer_related?
  alias_method :show?,   :admin_or_department_manager_or_volunteer_related?
  alias_method :last_submitted_hours_and_feedbacks?,
    :admin_or_department_manager_or_volunteer_related?
  alias_method :update_submitted_at?, :admin_or_department_manager_or_volunteer_related?
end
