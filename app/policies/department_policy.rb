class DepartmentPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :department
    def initialize(user, department)
      @user = user
      @department = department
    end

    def resolve
      if @user.superadmin?
        department.all
      else
        department.where(user: user)
      end
    end
  end

  attr_reader :user, :department

  def initialize(user, department)
    @user = user
    @department = department
  end

  delegate :superadmin?, to: :user
  delegate :department_manager?, to: :user

  def superadmin_or_the_departments_manager?
    superadmin? || department.user.include?(@user)
  end

  alias_method :index?,              :superadmin?
  alias_method :new?,                :superadmin?
  alias_method :create?,             :superadmin?
  alias_method :can_associate_user?, :superadmin?
  alias_method :destroy?,            :superadmin?

  alias_method :show?,               :superadmin_or_the_departments_manager?
  alias_method :edit?,               :superadmin_or_the_departments_manager?
  alias_method :update?,             :superadmin_or_the_departments_manager?

  def manager_with_department?
    department_manager? && user.manages_department?
  end

  def permitted_attributes
    return department_attributes.push(user_ids: []) if superadmin?
    return department_attributes if user.department_manager?
    []
  end

  private

  def department_attributes
    [
      contact_attributes: [
        :id, :last_name, :_destroy, :contactable_id, :contactable_type, :street,
        :extended, :city, :postal_code,
        contact_emails_attributes: ContactPoint::FORM_ATTRS,
        contact_phones_attributes: ContactPoint::FORM_ATTRS
      ]
    ]
  end
end
