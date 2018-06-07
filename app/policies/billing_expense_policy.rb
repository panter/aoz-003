class BillingExpensePolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      return scope.where(volunteer: user.volunteer) if volunteer?
      none
    end
  end

  alias_method :index?,                     :superadmin_or_volunteer?
  alias_method :download?,                  :superadmin_or_volunteer?
  alias_method :show?,                      :superadmin_or_volunteer_related?
  alias_method :new?,                       :superadmin?
  alias_method :edit?,                      :superadmin?
  alias_method :create?,                    :superadmin?
  alias_method :update?,                    :superadmin?
  alias_method :destroy?,                   :superadmin?
  alias_method :update_overwritten_amount?, :superadmin?
  alias_method :superadmin_privileges?,     :superadmin?
end
