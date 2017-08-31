class BillingExpensePolicy < ApplicationPolicy
  alias_method :index?,          :superadmin_or_volunteer_related?
  alias_method :show?,           :superadmin_or_volunteer_related?
  alias_method :new?,            :superadmin_or_volunteer_related?
  alias_method :edit?,           :superadmin_or_volunteer_related?
  alias_method :create?,         :superadmin_or_volunteer_related?
  alias_method :update?,         :superadmin_or_volunteer_related?
  alias_method :destroy?,        :superadmin_or_volunteer_related?
end
