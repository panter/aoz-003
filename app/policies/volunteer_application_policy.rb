class VolunteerApplicationPolicy < ApplicationPolicy
  attr_reader :user, :volunteer

  def initialize(user, volunteer)
    @user = user
    @volunteer = volunteer
  end

  def access_state?
    @user && (@user.superadmin? || @user.department_manager?)
  end
end
