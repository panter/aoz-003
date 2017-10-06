class VolunteerPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      return seeking_clients if department_manager? || social_worker?
      none
    end
    alias :seeking_clients :resolve
  end

  # controller action policies
  alias_method :index?,           :superadmin_or_department_manager?
  alias_method :new?,             :superadmin_or_department_manager?
  alias_method :create?,          :superadmin_or_department_manager?
  alias_method :seeking_clients?, :superadmin_or_department_manager?

  alias_method :destroy?,         :superadmin?
  alias_method :index_xls?,       :superadmin?

  def superadmin_departmentmanager_or_volunteers_profile?
    superadmin_or_department_manager? || user_owns_record?
  end

  alias_method :show?,   :superadmin_departmentmanager_or_volunteers_profile?
  alias_method :edit?,   :superadmin_departmentmanager_or_volunteers_profile?
  alias_method :update?, :superadmin_departmentmanager_or_volunteers_profile?

  # suplementary policies
  alias_method :can_manage?, :superadmin?
  alias_method :acceptance?, :superadmin?
  alias_method :checklist?,  :superadmin?
end
