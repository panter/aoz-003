class ClientPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      return resolve_owner if department_manager_or_social_worker?
      none
    end
  end

  # controller action policies
  alias_method :index?,       :superadmin_or_department_manager_or_social_worker?
  alias_method :search?,      :superadmin_or_department_manager_or_social_worker?
  alias_method :new?,         :superadmin_or_department_manager_or_social_worker?
  alias_method :create?,      :superadmin_or_department_manager_or_social_worker?
  alias_method :show?,        :superadmin_or_department_manager_or_social_worker?
  alias_method :edit?,        :superadmin_or_record_owner?
  alias_method :update?,      :superadmin_or_record_owner?
  alias_method :termination?, :superadmin_or_department_managers_record?
  alias_method :set_resigned?, :superadmin_or_department_managers_record?
  alias_method :destroy?,     :superadmin?

  # suplementary policies
  alias_method :superadmin_privileges?, :superadmin?

  def acceptance_collection
    if superadmin?
      Client.acceptance_collection
    elsif department_managers_record?
      Client.acceptance_collection_restricted
    end
  end
end
