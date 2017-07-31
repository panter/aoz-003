class ProfilePolicy < ApplicationPolicy
  alias_method :show?,   :superadmin_or_record_owner?
  alias_method :edit?,   :superadmin_or_record_owner?
  alias_method :create?, :superadmin_or_record_owner?
  alias_method :update?, :superadmin_or_record_owner?

  alias_method :new?,    :user_owns_record?
end
