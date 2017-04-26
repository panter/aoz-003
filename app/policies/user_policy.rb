class UserPolicy < ApplicationPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @user = model
  end

  def index?
    @current_user.admin_or_superadmin? || @current_user.social_worker?
  end

  def show?
    @current_user.superadmin? || @current_user == @user
  end

  def new?
    @current_user.admin_or_superadmin?
  end

  def edit?
    @current_user.superadmin? || @current_user == @user
  end

  def create?
    @current_user.admin_or_superadmin?
  end

  def update?
    @current_user.superadmin? || @current_user == @user
  end
end
