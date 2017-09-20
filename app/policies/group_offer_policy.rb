class GroupOfferPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return GroupOffer.none if all.empty?
      return GroupOffer.none if department_manager? && resolve_department.empty?
      return all if superadmin?
      resolve_department if department_manager?
    end
  end

  alias_method :index?,                 :superadmin_or_department_manager?
  alias_method :show?,                  :superadmin_or_departments_offer?
  alias_method :new?,                   :superadmin_or_department_manager?
  alias_method :edit?,                  :superadmin_or_departments_offer?
  alias_method :create?,                :superadmin_or_department_manager?
  alias_method :update?,                :superadmin_or_departments_offer?
  alias_method :destroy?,               :superadmin?
  alias_method :supervisor_privileges?, :superadmin?
end
