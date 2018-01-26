class VolunteerPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      return scope.seeking_clients.distinct if department_manager?
      none
    end
    alias :seeking_clients :resolve
  end

  def volunteer_managing_or_volunteers_profile?
    superadmin_or_department_manager_or_social_worker? || user_owns_record?
  end

  # controller action policies
  alias_method :index?,           :superadmin_or_department_manager_or_social_worker?
  alias_method :search?,          :superadmin_or_department_manager_or_social_worker?
  alias_method :new?,             :superadmin_or_department_manager_or_social_worker?
  alias_method :create?,          :superadmin_or_department_manager_or_social_worker?
  alias_method :seeking_clients?, :superadmin_or_department_manager?
  alias_method :terminate?,       :superadmin_or_department_managers_registration?
  alias_method :show?,            :volunteer_managing_or_volunteers_profile?
  alias_method :edit?,            :volunteer_managing_or_volunteers_profile?
  alias_method :update?,          :volunteer_managing_or_volunteers_profile?

  # supplementary policies
  alias_method :superadmin_privileges?, :superadmin?
end
