class VolunteerPolicy < ApplicationPolicy
  include AvailabilityAttributes
  include NestedAttributes
  include ContactAttributes
  include VolunteerAttributes

  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      return scope.where(department: user.department).or(scope.assignable_to_department) if department_manager?
      none
    end
  end

  def permitted_attributes
    attributes = [volunteer_attributes, :bank, :iban, :waive, :acceptance, :take_more_assignments,
      :external, :comments, :additional_comments, :working_percent]
    attributes << :department_id if superadmin_or_department_manager?
    attributes
  end

  def assignable_to_department?
    record_present? && record.assignable_to_department?
  end

  def superadmin_or_departments_record_or_assignable_to_department?
    superadmin? || department_manager? && (departments_record? || assignable_to_department?)
  end

  def volunteer_managing_or_volunteers_profile?
    superadmin_or_departments_record? ||
      superadmin_or_departments_record_or_assignable_to_department? ||
      user_owns_record?
  end

  # controller action policies
  alias_method :index?,           :superadmin_or_department_manager?
  alias_method :search?,          :superadmin_or_department_manager?
  alias_method :new?,             :superadmin_or_department_manager?
  alias_method :create?,          :superadmin_or_department_manager?
  alias_method :seeking_clients?, :superadmin_or_department_manager?
  alias_method :terminate?,       :superadmin_or_departments_record?
  alias_method :show?,            :volunteer_managing_or_volunteers_profile?
  alias_method :edit?,            :volunteer_managing_or_volunteers_profile?
  alias_method :update?,          :volunteer_managing_or_volunteers_profile?
  alias_method :account?,         :superadmin?

  # supplementary policies
  alias_method :superadmin_privileges?, :superadmin?
  alias_method :show_acceptance?,   :superadmin_or_department_manager?
  alias_method :show_comments?,     :superadmin_or_department_manager?
  alias_method :update_acceptance?, :superadmin_or_departments_record_or_assignable_to_department?
end
