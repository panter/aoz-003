class AssignmentJournalPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return resolve_assignment if superadmin?
      resolve_author_and_assignment if volunteer?
    end
  end

  alias_method :index?,          :superadmin_or_volunteer?
  alias_method :show?,           :superadmin_or_volunteers_entry?
  alias_method :new?,            :superadmin_or_volunteer_related?
  alias_method :edit?,           :superadmin_or_volunteers_entry?
  alias_method :create?,         :superadmin_or_volunteers_entry?
  alias_method :update?,         :superadmin_or_volunteers_entry?
  alias_method :destroy?,        :superadmin_or_volunteers_entry?
end
