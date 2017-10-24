class GroupAssignmentPolicy < ApplicationPolicy
  alias_method :show?, :admin_or_department_manager_or_volunteer_related?
end
