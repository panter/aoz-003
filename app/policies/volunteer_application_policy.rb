class VolunteerApplicationPolicy < ApplicationPolicy
  alias_method :new?,    :allow_all!
  alias_method :create?, :allow_all!
  alias_method :thanks?, :allow_all!
end
