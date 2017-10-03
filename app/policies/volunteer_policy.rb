class VolunteerPolicy < ApplicationPolicy
  alias_method :index?,           :superadmin?
  alias_method :new?,             :superadmin?
  alias_method :create?,          :superadmin?
  alias_method :destroy?,         :superadmin?
  alias_method :seeking_clients?, :superadmin_or_department_manager?
  alias_method :checklist?,       :superadmin?

  alias_method :show?,   :superadmin_or_volunteers_record?
  alias_method :edit?,   :superadmin_or_volunteers_record?
  alias_method :update?, :superadmin_or_volunteers_record?

  # credential policies
  alias_method :can_manage?, :superadmin?
end
