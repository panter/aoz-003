class VolunteerPolicy < ApplicationPolicy
  alias_method :index?,                 :superadmin?
  alias_method :new?,                   :superadmin?
  alias_method :create?,                :superadmin?
  alias_method :supervisor?,            :superadmin?
  alias_method :seeking_clients?,       :superadmin?

  alias_method :show?,                  :superadmin_or_volunteers_record?
  alias_method :edit?,                  :superadmin_or_volunteers_record?
  alias_method :update?,                :superadmin_or_volunteers_record?

  alias_method :destroy?,               :user_present_and_superadmin?
  alias_method :supervisor_privileges?, :user_present_and_superadmin?
  alias_method :checklist?,             :user_present_and_superadmin?
end
