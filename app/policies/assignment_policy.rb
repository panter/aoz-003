class AssignmentPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      all if superadmin?
    end
  end

  alias_method :index?,          :superadmin?
  alias_method :show?,           :superadmin?
  alias_method :new?,            :superadmin?
  alias_method :edit?,           :superadmin?
  alias_method :create?,         :superadmin?
  alias_method :update?,         :superadmin?
  alias_method :destroy?,        :superadmin?
  alias_method :find_volunteer?, :superadmin?
  alias_method :find_client?,    :superadmin?
end
