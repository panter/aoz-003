class HourPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      if department_manager?
        return scope.in_department_or_secondary_department(user.department).or(scope.assignable_to_department)
      end

      none
    end
  end

  def index?
    superadmin? || department_manager? || volunteer? && handle_record_or_class
  end

  def handle_record_or_class
    record.class == Class ? true : user.volunteer.id == record.volunteer_id
  end

  alias_method :supervisor?,     :superadmin?

  # Actions
  alias_method :show?,           :superadmin_or_department_manager_or_volunteer_related?
  alias_method :new?,            :superadmin_or_volunteer_related?
  alias_method :edit?,           :superadmin_or_volunteer_related?
  alias_method :create?,         :superadmin_or_volunteer_related?
  alias_method :update?,         :superadmin_or_volunteer_related?
  alias_method :destroy?,        :superadmin_or_volunteer_related?
  alias_method :mark_as_done?,   :superadmin?
end
