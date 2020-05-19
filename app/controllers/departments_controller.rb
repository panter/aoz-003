class DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :edit, :update, :destroy]

  def index
    authorize Department
    @q = policy_scope(Department).ransack(params[:q])
    @q.sorts = ['contact_last_name asc'] if @q.sorts.empty?
    @departments = @q.result
  end

  def show; end

  def new
    @department = Department.new
    authorize @department
  end

  def edit; end

  def create
    @department = Department.new
    authorize @department
    if @department.update(permitted_attributes(@department))
      redirect_to @department, make_notice
    else
      render :new
    end
  end

  def update
    if @department.update(permitted_attributes(@department))
      redirect_to @department, make_notice
    else
      render :edit
    end
  end

  def destroy
    if @department.destroy
      redirect_to departments_url, make_notice
    else
      redirect_to department_path(@department), notice: {
        message: 'Standort kann noch nicht gelöscht werden.',
        model_message: @department.errors.messages.values.flatten.join('; ')
      }.stringify_keys
    end
  end

  private

  def set_department
    @department = Department.find(params[:id])
    authorize @department
  end
end
