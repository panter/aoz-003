class SemesterFeedbackPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?

      scope.joins(:semester_process_volunteer, :volunteer).where(volunteers: { id: user.volunteer }) if volunteer?
    end
    end

  # Actions
  alias_method :review_semester?,        :superadmin_or_volunteer?
  alias_method :submit_review?,          :superadmin_or_volunteer?
  alias_method :index?,                  :superadmin_or_volunteer?
  end
