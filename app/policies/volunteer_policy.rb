class VolunteerPolicy < ApplicationPolicy
  alias_method :index?,                 :superadmin?
  alias_method :new?,                   :superadmin?
  alias_method :create?,                :superadmin?
  alias_method :destroy?,               :superadmin?
  alias_method :seeking_clients?,       :superadmin?
  alias_method :checklist?,             :superadmin?
  alias_method :volunteer_hours?,       :superadmin_or_volunteers_record?

  alias_method :show?,                  :superadmin_or_volunteers_record?
  alias_method :edit?,                  :superadmin_or_volunteers_record?
  alias_method :update?,                :superadmin_or_volunteers_record?

  alias_method :supervisor_privileges?, :superadmin?
  alias_method :supervisor?,            :superadmin?
end
