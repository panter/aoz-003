class FeedbackPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return resolve_assignment if superadmin?
      resolve_author_and_assignment if volunteer?
    end
  end

  alias_method :index?, :superadmin_or_volunteer?

  def superadmin_or_volunteers_feedback?
    binding.pry
    superadmin? || volunteer? && user.volunteer.id == record.volunteer.id
  end

  alias_method :new?,     :superadmin_or_volunteers_feedback?
  alias_method :show?,    :superadmin_or_volunteers_feedback?
  alias_method :edit?,    :superadmin_or_volunteers_feedback?
  alias_method :create?,  :superadmin_or_volunteers_feedback?
  alias_method :update?,  :superadmin_or_volunteers_feedback?
  alias_method :destroy?, :superadmin_or_volunteers_feedback?
end