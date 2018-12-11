class SemesterProcessPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?

      none
    end
  end

  # Actions
  alias_method :new?,     :superadmin?
  alias_method :edit?,    :superadmin?
  alias_method :create?,  :superadmin?
  alias_method :update?,  :superadmin?
  alias_method :overdue?,  :superadmin?
end
