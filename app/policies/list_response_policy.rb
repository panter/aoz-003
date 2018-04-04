class ListResponsePolicy < ApplicationPolicy
  alias_method :feedbacks?,        :superadmin?
  alias_method :trial_feedbacks?,  :superadmin?
end
