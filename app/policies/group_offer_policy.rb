class GroupOfferPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      superadmin? || department_manager? ? all : none
    end
  end

  def superadmin_or_department_manager_is_responsible?
    superadmin? || department_manager? && (user.department.any? || user.group_offers.any?)
  end

  # controller action policies
  alias_method :index?,  :superadmin_or_department_manager?
  alias_method :search?, :superadmin_or_department_manager?
  alias_method :new?,    :superadmin_or_department_manager_is_responsible?
  alias_method :create?, :superadmin_or_department_manager_is_responsible?

  alias_method :show?,             :superadmin_or_department_manager_or_volunteer_included?
  alias_method :search_volunteer?, :superadmin_or_departments_offer_or_volunteer_included?

  alias_method :edit?,                        :superadmin_or_department_manager_offer?
  alias_method :update?,                      :superadmin_or_department_manager_offer?
  alias_method :change_active_state?,         :superadmin_or_department_manager_offer?
  alias_method :initiate_termination?,        :superadmin_or_department_manager_offer?
  alias_method :submit_initiate_termination?, :superadmin_or_department_manager_offer?
  alias_method :end_all_assignments?,         :superadmin_or_department_manager_offer?

  # supplemental policies
  alias_method :supervisor_privileges?, :superadmin?
  alias_method :show_comments?,         :superadmin_or_department_manager_is_responsible?
end
