class VolunteerApplicationPolicy < ApplicationPolicy
  attr_reader :user, :volunteer

  def initialize(user, volunteer)
    @user = user
    @volunteer = volunteer
  end
end
