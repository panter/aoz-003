class FeedbackPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      scope.where(volunteer: user.volunteer, author: user) if volunteer?
    end
  end

  def superadmin_or_volunteers_feedback?
    superadmin? || volunteer? && of_and_from_volunteer? && in_feedbackable?
  end

  def of_and_from_volunteer?
    user.volunteer.id == record.volunteer.id && user.id == record.author.id
  end

  def in_feedbackable?
    if record.feedbackable.class == Assignment
      record.feedbackable.volunteer.id == user.volunteer.id
    else
      record.feedbackable.volunteers.ids.include? user.volunteer.id
    end
  end

  alias_method :index?,   :superadmin_or_volunteer?
  alias_method :new?,     :superadmin_or_volunteers_feedback?
  alias_method :show?,    :superadmin_or_volunteers_feedback?
  alias_method :edit?,    :superadmin_or_volunteers_feedback?
  alias_method :create?,  :superadmin_or_volunteers_feedback?
  alias_method :update?,  :superadmin_or_volunteers_feedback?
  alias_method :destroy?, :superadmin_or_volunteers_feedback?
end
