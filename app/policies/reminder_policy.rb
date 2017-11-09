class ReminderPolicy < ApplicationPolicy
  alias_method :index?,     :superadmin?
  alias_method :update?,    :superadmin?
  alias_method :destroy?,   :superadmin?
  alias_method :trial_end?, :superadmin?
end
