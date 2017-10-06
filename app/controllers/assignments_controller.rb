class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :destroy]
  before_action :set_volunteer, only: [:find_client]
  before_action :set_client, only: [:find_volunteer]

  def index
    authorize Assignment
    @q = policy_scope(Assignment).ransack(params[:q])
    @assignments = @q.result.default_order.paginate(page: params[:page])
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "assignment_#{@assignment.id}", template: 'assignments/show.html.slim',
          layout: 'pdf.pdf', encoding: 'UTF-8'
      end
    end
  end

  def new
    @assignment = Assignment.new
    authorize @assignment
  end

  def edit; end

  def create
    @assignment = Assignment.new(assignment_params.merge(creator_id: current_user.id))
    @assignment.client.state = Client::RESERVED
    authorize @assignment
    if @assignment.save
      redirect_to assignments_url, make_notice
    else
      render :new
    end
  end

  def update
    if @assignment.update(assignment_params)
      redirect_to(volunteer? ? @assignment.volunteer : assignments_url, make_notice)
    else
      render :edit
    end
  end

  def destroy
    client = @assignment.client
    @assignment.destroy
    client.update(state: Client::REGISTERED)
    redirect_to assignments_url, make_notice
  end

  def find_volunteer
    @q = policy_scope(Volunteer).seeking_clients.ransack(params[:q])
    @seeking_clients = @q.result
  end

  def find_client
    @q = Client.need_accompanying.ransack(params[:q])
    @need_accompanying = @q.result
    @need_accompanying = @need_accompanying.paginate(page: params[:page])
  end

  private

  def set_client
    @client = Client.find(params[:id])
    authorize Assignment
  end

  def set_volunteer
    @volunteer = Volunteer.find(params[:id])
    authorize Assignment
  end

  def set_assignment
    @assignment = Assignment.find(params[:id])
    authorize @assignment
  end

  def assignment_params
    params.require(:assignment).permit(:client_id, :volunteer_id, :state, :period_start,
      :period_end, :performance_appraisal_review, :probation_period, :home_visit,
      :first_instruction_lesson, :confirmation)
  end
end
