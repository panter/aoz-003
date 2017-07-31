class VolunteerEmailPolicy < ApplicationPolicy
  attr_reader :user, :volunteer_email

  def initialize(user, volunteer_email)
    @user = user
    @volunteer_email = volunteer_email
  end

  delegate :superadmin?, to: :user

  alias_method :index?,   :superadmin?
  alias_method :show?,    :superadmin?
  alias_method :edit?,    :superadmin?
  alias_method :create?,  :superadmin?
  alias_method :update?,  :superadmin?
  alias_method :destroy?, :superadmin?
  alias_method :supervisor_privileges?, :superadmin?
end
