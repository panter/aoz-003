class DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :edit, :update, :destroy]

  def index
    @departments = policy_scope(Department)
  end

  def show
    authorize @department
  end

  def new
    @department = Department.new
    @department.build_contact
    authorize @department
  end

  def edit
    authorize @department
  end

  def create
    @department = Department.new(department_params)
    authorize @department
    if @department.save
      redirect_to @department, notice: t('department_created')
    else
      render :new
    end
  end

  def update
    authorize @department
    if @department.update(department_params)
      redirect_to @department, notice: t('department_updated')
    else
      render :edit
    end
  end

  def destroy
    authorize @department
    @department.destroy
    redirect_to departments_url, notice: t('department_destroyed')
  end

  private

  def set_department
    @department = Department.find(params[:id])
  end

  def phone_attrs
    [:id, :body, :label, :_destroy, :type, :contacts_id]
  end

  def email_attrs
    [:id, :body, :label, :_destroy, :type, :contacts_id]
  end

  def contact_attrs
    [
      :id, :name, :_destroy, :contactable_id, :contactable_type, :street,
      :extended, :city, :postal_code,
      contact_emails_attributes: email_attrs,
      contact_phones_attributes: phone_attrs
    ]
  end

  def department_params
    params.require(:department).permit(user_ids: [], contact_attributes: contact_attrs)
  end
end
