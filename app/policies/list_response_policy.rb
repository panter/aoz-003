class ListResponsePolicy < ApplicationPolicy
  alias_method :feedbacks?, :superadmin?
  alias_method :hours?, :superadmin?
  alias_method :mark_feedback_done?, :superadmin?
  alias_method :mark_trial_feedback_done?, :superadmin?
  alias_method :mark_hour_done?, :superadmin?
end
