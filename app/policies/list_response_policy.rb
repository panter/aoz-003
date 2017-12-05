class ListResponsePolicy < ApplicationPolicy
  alias_method :feedbacks?, :superadmin?
  alias_method :hours?, :superadmin?
end
