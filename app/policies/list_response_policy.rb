class ListResponsePolicy < ApplicationPolicy
  alias_method :trial_feedbacks?,  :superadmin?
end
