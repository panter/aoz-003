class AssignmentsController < ApplicationController
  include MakeNotice

  before_action :set_assignment, only: [:show, :edit, :update, :destroy]

  def index
    @assignments = Assignment.all
    authorize Assignment
  end

  def show
    @assignment = Assignment.find(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "assignment_#{@assignment.id}", template: 'assignments/show.html.slim', layout: 'pdf.pdf', encoding: 'UTF-8'
      end
    end
  end

  def new
    @assignment = Assignment.new
    authorize @assignment
  end

  def edit; end

  def create
    @assignment = Assignment.new(assignment_params)
    @assignment.creator = current_user
    authorize @assignment
    if @assignment.save
      @assignment.client.state = Client::RESERVED
      @assignment.client.save
      @assignment.volunteer.state = Volunteer::ACTIVE
      @assignment.volunteer.save
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
    client = @assignment.client
    volunteer = @assignment.volunteer
    @assignment.destroy
    client.state = Client::REGISTERED
    client.save
    if Volunteer.without_clients.include?(volunteer)
      volunteer.state = Volunteer::ACCEPTED
      volunteer.save
    end
    redirect_to assignments_url, make_notice
  end

  def find_volunteer
    @client = Client.find(params[:id])
    @q = Volunteer.without_clients.ransack(params[:q])
    @without_clients = @q.result
    authorize Assignment
  end

  def find_client
    @volunteer = Volunteer.find(params[:id])
    @q = Client.need_accompanying.ransack(params[:q])
    @need_accompanying = @q.result
    authorize Assignment
  end

  private

  def set_assignment
    @assignment = Assignment.find(params[:id])
    authorize @assignment
  end

  def assignment_params
    params.require(:assignment).permit(:client_id, :volunteer_id, :state)
  end
end
