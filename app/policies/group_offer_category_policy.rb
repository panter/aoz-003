class GroupOfferCategoryPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      if superadmin?
        all
      elsif department_manager?
        all
      else
        none
      end
    end
  end

  alias_method :index?,                 :superadmin_or_department_manager?
  alias_method :show?,                  :superadmin_or_department_manager?
  alias_method :new?,                   :superadmin_or_department_manager?
  alias_method :edit?,                  :superadmin_or_department_manager?
  alias_method :create?,                :superadmin_or_department_manager?
  alias_method :update?,                :superadmin_or_department_manager?
end
