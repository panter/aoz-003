class GroupOfferPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      if superadmin?
        all
      elsif department_manager?
        resolve_department
      else
        none
      end
    end
  end

  def superadmin_or_department_manager_has_department?
    superadmin? || department_manager? && user.department.any?
  end

  # controller action policies
  alias_method :index?,               :superadmin_or_department_manager_has_department?
  alias_method :search?,              :superadmin_or_department_manager_has_department?
  alias_method :new?,                 :superadmin_or_department_manager_has_department?
  alias_method :create?,              :superadmin_or_department_manager_has_department?
  alias_method :show?,                :superadmin_or_departments_offer_or_volunteer_included?
  alias_method :edit?,                :superadmin_or_departments_offer?
  alias_method :update?,              :superadmin_or_departments_offer?
  alias_method :archived?,            :superadmin_or_department_manager?
  alias_method :change_active_state?, :superadmin_or_departments_offer?

  alias_method :destroy?, :superadmin?

  # supplemental policies
  alias_method :supervisor_privileges?, :superadmin?
  alias_method :department?, :superadmin?
end
