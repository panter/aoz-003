class ReminderPolicy < ApplicationPolicy
  alias_method :index?,   :superadmin?
  alias_method :update?,  :superadmin?
  alias_method :destroy?, :superadmin?
end
