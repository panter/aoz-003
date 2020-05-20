class FeedbackPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?

      scope.joins(:semester_process_volunteer, :volunteer).where(volunteers: { id: user.volunteer }) if volunteer?
    end
    end

  alias_method :index?, :superadmin_or_volunteer?
  end
