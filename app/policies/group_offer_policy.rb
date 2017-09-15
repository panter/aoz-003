class GroupOfferPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      resolve_department if department_manager?
    end
  end

  alias_method :index?,          :superadmin_or_department_manager?
  alias_method :show?,           :superadmin_or_departments_offer?
  alias_method :new?,            :superadmin_or_department_manager?
  alias_method :edit?,           :superadmin_or_departments_offer?
  alias_method :create?,         :superadmin_or_department_manager?
  alias_method :update?,         :superadmin_or_departments_offer?
  alias_method :destroy?,        :superadmin?
end
