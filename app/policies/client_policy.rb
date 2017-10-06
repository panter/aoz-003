class ClientPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      return resolve_owner if department_manager_or_social_worker?
      none
    end
  end

  # controller action policies
  alias_method :index?,  :volunteer_managing_user?
  alias_method :new?,    :volunteer_managing_user?
  alias_method :create?, :volunteer_managing_user?

  alias_method :show?,   :superadmin_or_social_workers_record?
  alias_method :edit?,   :superadmin_or_social_workers_record?
  alias_method :update?, :superadmin_or_social_workers_record?

  alias_method :destroy?,           :superadmin?
  alias_method :need_accompanying?, :volunteer_managing_user?

  # suplementary policies
  alias_method :supervisor?, :superadmin?
  alias_method :journals?,   :superadmin?
  alias_method :comments?,   :superadmin?
end
