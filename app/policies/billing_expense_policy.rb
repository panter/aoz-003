class BillingExpensePolicy < ApplicationPolicy
  def index?
    superadmin? || volunteer? && handle_record_or_class
  end

  def handle_record_or_class
    record.class == Class ? true : user.volunteer.id == record.volunteer.id
  end

  alias_method :show?,    :superadmin_or_volunteers_record?
  alias_method :new?,     :superadmin?
  alias_method :edit?,    :superadmin?
  alias_method :create?,  :superadmin?
  alias_method :update?,  :superadmin?
  alias_method :destroy?, :superadmin?
  alias_method :superadmin_privileges?, :superadmin?
end
