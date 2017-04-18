class UserPolicy < ApplicationPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @user = model
  end

  def index?
    @current_user.admin_superadmin?
  end

  def show?
    @current_user.superadmin? || @current_user == @user
  end

  def update?
    @current_user.superadmin? || @current_user == @user
  end
end
