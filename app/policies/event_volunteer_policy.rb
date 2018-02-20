class EventVolunteerPolicy < ApplicationPolicy
  alias_method :create?,  :superadmin?
  alias_method :update?,  :superadmin?
  alias_method :destroy?, :superadmin?
end
