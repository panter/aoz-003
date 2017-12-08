class HourPolicy < ApplicationPolicy
  def index?
    superadmin? || volunteer? && handle_record_or_class
  end

  def handle_record_or_class
    record.class == Class ? true : user.volunteer.id == record.volunteer.id
  end

  alias_method :supervisor?,     :superadmin?

  # Actions
  alias_method :show?,           :superadmin_or_volunteer_related?
  alias_method :new?,            :superadmin_or_volunteer_related?
  alias_method :edit?,           :superadmin_or_volunteer_related?
  alias_method :create?,         :superadmin_or_volunteer_related?
  alias_method :update?,         :superadmin_or_volunteer_related?
  alias_method :destroy?,        :superadmin_or_volunteer_related?
  alias_method :mark_as_done?,   :superadmin?
end
