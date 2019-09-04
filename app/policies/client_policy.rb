class ClientPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      return resolve_owner if department_manager?
      return resolve_owner.or(scope.where(involved_authority: user)) if social_worker?
      none
    end
  end

  def superadmin_or_client_responsible?
    superadmin? || department_managers_record? || social_worker_owns_or_authority?
  end

  def social_worker_owns_or_authority?
    social_worker? && (user_owns_record? || user_involved_authority?)
  end

  def reactivate?
    record.class.name == 'Client' && record.resigned? &&
      superadmin_or_client_responsible?
  end

  # controller action policies
  alias_method :index?,          :superadmin_or_department_manager_or_social_worker?
  alias_method :search?,         :superadmin_or_department_manager_or_social_worker?
  alias_method :new?,            :superadmin_or_department_manager_or_social_worker?
  alias_method :create?,         :superadmin_or_department_manager_or_social_worker?
  alias_method :show?,           :superadmin_or_department_manager_or_social_worker?
  alias_method :destroy?,        :superadmin_or_client_responsible?
  alias_method :edit?,           :superadmin_or_client_responsible?
  alias_method :update?,         :superadmin_or_client_responsible?
  alias_method :set_terminated?, :superadmin_or_department_managers_record?

  # suplementary policies
  alias_method :superadmin_privileges?, :superadmin?
  alias_method :show_comments?, :superadmin_or_department_manager?

  def acceptance_collection
    if superadmin_or_department_managers_record?
      Client.acceptance_collection
    else
      Client.acceptance_collection_restricted
    end
  end
end
