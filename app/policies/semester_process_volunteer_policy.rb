class SemesterProcessVolunteerPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      none
    end
  end

  # Actions
  alias_method :index?,               :superadmin?
  alias_method :review_semester?,     :superadmin_or_volunteer_related?
  alias_method :submit_review?,       :superadmin_or_volunteer_related?
  alias_method :new?,                 :superadmin?
  alias_method :show?,                :superadmin?
  alias_method :edit?,                :superadmin?
  alias_method :create?,              :superadmin?
  alias_method :update?,              :superadmin?
  alias_method :destroy?,             :superadmin?
  alias_method :take_responsibility?, :superadmin?
  alias_method :mark_as_done?,        :superadmin?
end
