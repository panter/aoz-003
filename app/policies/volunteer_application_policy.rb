class VolunteerApplicationPolicy < ApplicationPolicy
  attr_reader :user, :volunteer

  def initialize(user, volunteer)
    @user = user
    @volunteer = volunteer
  end

  def all_access
    true
  end
  alias_method :new?,    :all_access
  alias_method :create?, :all_access
  alias_method :thanks?, :all_access
end
