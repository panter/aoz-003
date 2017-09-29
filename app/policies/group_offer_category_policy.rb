class GroupOfferCategoryPolicy < ApplicationPolicy
  alias_method :index?,                 :superadmin_or_department_manager?
  alias_method :show?,                  :superadmin_or_department_manager?
  alias_method :new?,                   :superadmin_or_department_manager?
  alias_method :edit?,                  :superadmin_or_department_manager?
  alias_method :create?,                :superadmin_or_department_manager?
  alias_method :update?,                :superadmin_or_department_manager?
end
