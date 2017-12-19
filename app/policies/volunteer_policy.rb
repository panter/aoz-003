class VolunteerPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      return scope.seeking_clients.distinct if department_manager_or_social_worker?
      none
    end
    alias :seeking_clients :resolve
  end

  # controller action policies
  alias_method :index?,           :superadmin_or_department_manager_or_social_worker?
  alias_method :seeking_clients?, :superadmin_or_department_manager_or_social_worker?

  alias_method :search?,          :user_managing_volunteer?
  alias_method :new?,             :user_managing_volunteer?
  alias_method :create?,          :user_managing_volunteer?

  alias_method :destroy?,         :superadmin?
  alias_method :index_xls?,       :superadmin?

  def volunteer_managing_or_volunteers_profile?
    user_managing_volunteer? || user_owns_record?
  end

  alias_method :show?,   :volunteer_managing_or_volunteers_profile?
  alias_method :edit?,   :volunteer_managing_or_volunteers_profile?
  alias_method :update?, :volunteer_managing_or_volunteers_profile?

  # suplementary policies
  alias_method :can_manage?, :superadmin?
  alias_method :acceptance?, :superadmin?
  alias_method :checklist?,  :superadmin?
  alias_method :state?,      :superadmin?
end
