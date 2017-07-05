class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :destroy]

  def index
    @assignments = Assignment.all
    @without_assignments = Client.without_assignments
  end

  def show; end

  def new
    @assignment = Assignment.new
  end

  def edit; end

  def create
    @assignment = Assignment.new(assignment_params)
    @assignment.to_pdf

    if @assignment.save
      redirect_to(assignments_url, notice: 'Assignment was successfully created.')
    else
      render :new
    end
  end

  def update
    if @assignment.update(assignment_params)
      redirect_to assignments_url, notice: 'Assignment was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @assignment.destroy
    redirect_to assignments_url, notice: 'Assignment was successfully destroyed.'
  end

  private

  def set_assignment
    @assignment = Assignment.find(params[:id])
  end

  def assignment_params
    params.require(:assignment).permit(:client_id, :volunteer_id)
  end
end
