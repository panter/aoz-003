class GroupAssignmentPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      superadmin? || department_manager? ? all : none
    end
  end

  alias_method :show?,
    :superadmin_or_department_manager_or_volunteer_related?

  alias_method :create?,             :superadmin_or_department_manager_offer?
  alias_method :edit?,               :superadmin_or_department_manager_offer?
  alias_method :update?,             :superadmin_or_department_manager_offer?
  alias_method :set_end_today?,      :superadmin_or_department_manager_offer?
  alias_method :verify_termination?, :superadmin_or_department_manager_offer?

  alias_method :terminated_index?, :superadmin_or_department_manager?

  alias_method :hours_and_feedbacks_submitted?,
    :superadmin_or_department_manager_or_volunteer?
  alias_method :last_submitted_hours_and_feedbacks?,
    :superadmin_or_department_manager_or_volunteer_related?
  alias_method :submit_feedback?,      :superadmin_or_departments_offer_or_volunteer_related?
  alias_method :terminate?,            :superadmin_or_departments_offer_or_volunteer_related?
  alias_method :update_terminated_at?, :superadmin_or_departments_offer_or_volunteer_related?

  alias_method :show_comments?, :superadmin_or_department_manager?
end
