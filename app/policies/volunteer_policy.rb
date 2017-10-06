class VolunteerPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      return seeking_clients if department_manager_or_social_worker?
      none
    end
    alias :seeking_clients :resolve
  end

  # controller action policies
  alias_method :index?,           :volunteer_managing_user?
  alias_method :new?,             :volunteer_managing_user?
  alias_method :create?,          :volunteer_managing_user?
  alias_method :seeking_clients?, :volunteer_managing_user?

  alias_method :destroy?,         :superadmin?
  alias_method :index_xls?,       :superadmin?

  def volunteer_managing_or_volunteers_profile?
    volunteer_managing_user? || user_owns_record?
  end

  alias_method :show?,   :volunteer_managing_or_volunteers_profile?
  alias_method :edit?,   :volunteer_managing_or_volunteers_profile?
  alias_method :update?, :volunteer_managing_or_volunteers_profile?

  # suplementary policies
  alias_method :can_manage?, :superadmin?
  alias_method :acceptance?, :superadmin?
  alias_method :checklist?,  :superadmin?
end
