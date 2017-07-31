class UserPolicy < ApplicationPolicy
  attr_reader :current_user, :subject_user

  def initialize(current_user, subject_user)
    @current_user = current_user
    @subject_user = subject_user
  end

  delegate :superadmin?, to: :current_user

  def superadmin_and_subject_not_superadmin?
    superadmin? && !subject_user.superadmin?
  end

  def superadmin_or_current_user_is_subject?
    superadmin? || current_user == subject_user
  end

  alias_method :index?,   :superadmin?
  alias_method :new?,     :superadmin?
  alias_method :create?,  :superadmin?

  alias_method :show?,    :superadmin_or_current_user_is_subject?
  alias_method :edit?,    :superadmin_or_current_user_is_subject?
  alias_method :update?,  :superadmin_or_current_user_is_subject?

  alias_method :destroy?, :superadmin_and_subject_not_superadmin?
end
