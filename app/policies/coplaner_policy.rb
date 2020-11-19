class CoplanerPolicy < ApplicationPolicy
  alias_method :index?, :superadmin?
end
