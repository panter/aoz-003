class VolunteerEmailPolicy < ApplicationPolicy
  alias_method :index?,                 :superadmin?
  alias_method :show?,                  :superadmin?
  alias_method :edit?,                  :superadmin?
  alias_method :create?,                :superadmin?
  alias_method :update?,                :superadmin?
  alias_method :destroy?,               :superadmin?
  alias_method :supervisor_privileges?, :superadmin?
end
