class AssignmentPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      return scope.where(creator_id: user.id) if department_manager_or_social_worker?
      none
    end
    alias :seeking_clients :resolve

    def need_accompanying
      return scope.need_accompanying if superadmin? || department_manager_or_social_worker?
      none
    end
  end

  # controller action policies
  alias_method :index?,          :superadmin_or_department_manager?
  alias_method :new?,            :superadmin_or_department_manager?
  alias_method :create?,         :superadmin_or_department_manager?
  alias_method :find_volunteer?, :superadmin_or_department_manager?
  alias_method :find_client?,    :superadmin_or_department_manager?

  alias_method :show?,   :admin_or_department_manager_or_volunteer_related?
  alias_method :last_submitted_hours_and_feedbacks?,
    :admin_or_department_manager_or_volunteer_related?
  alias_method :edit?,   :admin_or_department_manager_or_volunteer_related?
  alias_method :update?, :admin_or_department_manager_or_volunteer_related?
  alias_method :update_submitted_at?, :admin_or_department_manager_or_volunteer_related?

  alias_method :destroy?, :superadmin?

  # supplemental policies
  alias_method :supervisor?, :superadmin_or_department_manager?
end
