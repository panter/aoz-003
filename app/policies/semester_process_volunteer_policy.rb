class SemesterProcessVolunteerPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?

      none
    end
  end

  # Actions
  alias_method :index?,  :superadmin?
  alias_method :show?,   :superadmin?
  alias_method :update?, :superadmin?
  alias_method :edit?,   :superadmin?
end
