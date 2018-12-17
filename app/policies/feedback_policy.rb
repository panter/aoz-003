class FeedbackPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      scope.where(volunteer: user.volunteer, author: user) if volunteer?
    end
  end

  alias_method :index?,               :superadmin_or_volunteer?
  alias_method :show?,                :superadmin_or_feedback_about_volunteer?
end
