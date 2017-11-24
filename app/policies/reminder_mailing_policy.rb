class ReminderMailingPolicy < ApplicationPolicy
  alias_method :index?,                :superadmin?
  alias_method :new_half_year?,        :superadmin?
  alias_method :new_probation_period?, :superadmin?
  alias_method :show?,                 :superadmin?
  alias_method :initiate_mailing?,     :superadmin?
  alias_method :create?,               :superadmin?
  alias_method :edit?,                 :superadmin?
  alias_method :update?,               :superadmin?
  alias_method :destroy?,              :superadmin?
end
