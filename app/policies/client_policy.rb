class ClientPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      return resolve_owner if department_manager_or_social_worker?
      none
    end
  end

  # controller action policies
  alias_method :index?,  :user_managing_volunteer?
  alias_method :new?,    :user_managing_volunteer?
  alias_method :create?, :user_managing_volunteer?

  alias_method :show?,   :user_managing_volunteer?
  alias_method :edit?,   :superadmin_or_social_workers_record?
  alias_method :update?, :superadmin_or_social_workers_record?

  alias_method :destroy?,           :superadmin?
  alias_method :need_accompanying?, :superadmin_or_department_manager?
  alias_method :with_assignment?,   :superadmin_or_department_manager?

  # suplementary policies
  alias_method :comments?,         :superadmin?
  alias_method :state?,            :superadmin?
end
