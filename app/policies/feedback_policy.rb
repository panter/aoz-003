class FeedbackPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      scope.where(volunteer: user.volunteer, author: user) if volunteer?
    end
  end

  alias_method :index?,        :superadmin_or_volunteer?
  alias_method :new?,          :superadmin_or_volunteers_feedback?
  alias_method :show?,         :superadmin_or_volunteers_feedback?
  alias_method :edit?,         :superadmin_or_volunteers_feedback?
  alias_method :create?,       :superadmin_or_volunteers_feedback?
  alias_method :update?,       :superadmin_or_volunteers_feedback?
  alias_method :destroy?,      :superadmin_or_volunteers_feedback?
  alias_method :mark_as_done?, :superadmin?
end
