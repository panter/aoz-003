class DepartmentPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :department
    def initialize(user, department)
      @user = user
      @department = department
    end

    def resolve
      if @user.superadmin?
        @department.all
      else
        @department.where(user: @user)
      end
    end
  end

  def initialize(user, department)
    @user = user
    @department = department
  end

  def permitted_attributes
    return department_attributes.push(user_ids: []) if @user.superadmin?
    return department_attributes if @user.department_manager?
    []
  end

  def index?
    @user.superadmin?
  end

  def show?
    superadmin_or_the_departments_manager?
  end

  def new?
    @user.superadmin?
  end

  def edit?
    superadmin_or_the_departments_manager?
  end

  def create?
    @user.superadmin?
  end

  def can_associate_user?
    @user.superadmin?
  end

  def manager_with_department?
    @user.department_manager? && @user.with_department?
  end

  def update?
    superadmin_or_the_departments_manager?
  end

  def destroy?
    @user.superadmin?
  end

  private

  def superadmin_or_the_departments_manager?
    @user.superadmin? || @department.user.include?(@user)
  end

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
