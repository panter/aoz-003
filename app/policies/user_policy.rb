class UserPolicy < ApplicationPolicy
  def superadmin_and_subject_not_superadmin?
    superadmin? && !record.superadmin?
  end

  def superadmin_or_current_user_is_subject?
    superadmin? || user == record
  end

  alias_method :index?,   :superadmin?
  alias_method :search?,  :superadmin?
  alias_method :new?,     :superadmin?
  alias_method :create?,  :superadmin?

  alias_method :show?,    :superadmin_or_current_user_is_subject?
  alias_method :edit?,    :superadmin_or_current_user_is_subject?
  alias_method :update?,  :superadmin_or_current_user_is_subject?

  alias_method :destroy?, :superadmin_and_subject_not_superadmin?
end
