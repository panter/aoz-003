class ReminderMailingPolicy < ApplicationPolicy
  alias_method :index?,                :superadmin?
  alias_method :new_half_year?,        :superadmin?
  alias_method :new_trial_period?,     :superadmin?
  alias_method :show?,                 :superadmin?
  alias_method :send_trial_period?,    :superadmin?
  alias_method :send_half_year?,       :superadmin?
  alias_method :create?,               :superadmin?
  alias_method :edit?,                 :superadmin?
  alias_method :update?,               :superadmin?
  alias_method :destroy?,              :superadmin?
end
