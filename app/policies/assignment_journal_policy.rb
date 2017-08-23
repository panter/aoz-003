class AssignmentJournalPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      all if superadmin?
    end
  end

  alias_method :index?,          :superadmin?
  alias_method :show?,           :superadmin_or_volunteers_entry?
  alias_method :new?,            :superadmin_or_volunteer_related?
  alias_method :edit?,           :superadmin_or_volunteers_entry?
  alias_method :create?,         :superadmin_or_volunteers_entry?
  alias_method :update?,         :superadmin_or_volunteers_entry?
  alias_method :destroy?,        :superadmin_or_volunteers_entry?
end
