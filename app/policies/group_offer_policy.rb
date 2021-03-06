class GroupOfferPolicy < ApplicationPolicy
  include GroupAssignmentsAttributes

  class Scope < ApplicationScope
    def resolve
      superadmin? || department_manager? ? all : none
    end
  end

  def permitted_attributes
    attributes = [
      :title, :offer_type, :offer_state, :necessary_volunteers, :description,
      :women, :men, :children, :teenagers, :unaccompanied, :all, :long_term, :regular,
      :short_term, :workday, :weekend, :morning, :afternoon, :evening, :flexible, :schedule_details,
      :creator_id, :organization, :location, :period_end, :group_offer_category_id,
      group_assignments_attributes
    ]
    attributes << :department_id if edit?
    attributes
  end

  def superadmin_or_department_manager_is_responsible?
    superadmin? || department_manager? && (user.department.any? || user.group_offers.any?)
  end

  # actions on collection
  alias_method :index?,  :superadmin_or_department_manager?
  alias_method :search?, :superadmin_or_department_manager?

  # actions related to creating a member
  alias_method :new?,              :superadmin_or_deparment_manager_has_department?
  alias_method :create?,           :superadmin_or_deparment_manager_has_department?

  # actions related to editing a member
  alias_method :edit?,                        :superadmin_or_department_manager_offer?
  alias_method :update?,                      :superadmin_or_department_manager_offer?
  alias_method :change_active_state?,         :superadmin_or_department_manager_offer?
  alias_method :initiate_termination?,        :superadmin_or_department_manager_offer?
  alias_method :submit_initiate_termination?, :superadmin_or_department_manager_offer?
  alias_method :end_all_assignments?,         :superadmin_or_department_manager_offer?
  alias_method :search_volunteer?,            :superadmin_or_departments_offer_or_volunteer_included?

  # action related to showing a member
  alias_method :show?, :superadmin_or_department_manager_or_volunteer_included?

  # supplemental privileges
  alias_method :show_comments?,         :superadmin_or_department_manager_offer?
  alias_method :supervisor_privileges?, :superadmin?
end
