class DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :edit, :update, :destroy]

  def index
    @departments = Department.all
  end

  def show; end

  def new
    @department = Department.new
    authorize @department
  end

  def edit; end

  def create
    @department = Department.new(department_params)
    respond_to do |format|
      if @department.save
        format.html do
          redirect_to @department, notice: t('Department was successfully created.')
        end
      else
        format.html { render :new }
      end
    end
    authorize @department
  end

  def update
    respond_to do |format|
      if @department.update(department_params)
        format.html do
          redirect_to @department, notice: t('Department was successfully updated.')
        end
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @department.destroy
    respond_to do |format|
      format.html do
        redirect_to departments_url, notice: t('Department was successfully destroyed.')
      end
    end
    authorize @department
  end

  private

  def set_department
    @department = Department.find(params[:id])
  end

  def department_params
    params.require(:department).permit(:name, :street, :zip, :place, :phone, :email, :user_id)
  end
end
