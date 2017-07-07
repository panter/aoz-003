class AssignmentsController < ApplicationController
  include MakeNotice

  before_action :set_assignment, only: [:show, :edit, :update, :destroy]

  def index
    @assignments = Assignment.all
    authorize Assignment
  end

  def show; end

  def new
    @assignment = Assignment.new
    authorize @assignment
  end

  def edit; end

  def create
    @assignment = Assignment.new(assignment_params)
    @assignment.to_pdf
    authorize @assignment
    if @assignment.save
      redirect_to assignments_url, make_notice
    else
      render :new
    end
  end

  def update
    if @assignment.update(assignment_params)
      redirect_to assignments_url, make_notice
    else
      render :edit
    end
  end

  def destroy
    @assignment.destroy
    redirect_to assignments_url, make_notice
  end

  def find_volunteer
    @client = Client.find(params[:client_id])
    @without_clients = Volunteer.without_clients
    authorize Assignment
  end

  private

  def set_assignment
    @assignment = Assignment.find(params[:id])
    authorize @assignment
  end

  def assignment_params
    params.require(:assignment).permit(:client_id, :volunteer_id)
  end
end
