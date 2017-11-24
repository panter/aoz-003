class ClientNotificationPolicy < ApplicationPolicy
  # controller action policies
  alias_method :index?,           :superadmin?
  alias_method :new?,             :superadmin?
  alias_method :edit?,            :superadmin?
  alias_method :create?,          :superadmin?
  alias_method :update?,          :superadmin?
  alias_method :destroy?,         :superadmin?
end
