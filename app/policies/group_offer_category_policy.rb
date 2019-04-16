class GroupOfferCategoryPolicy < ApplicationPolicy
  alias_method :index?,  :superadmin_or_department_manager?
  alias_method :show?,   :superadmin_or_department_manager?
  alias_method :new?,    :superadmin?
  alias_method :edit?,   :superadmin?
  alias_method :create?, :superadmin?
  alias_method :update?, :superadmin?
end
