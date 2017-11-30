class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :destroy,
                                        :last_submitted_hours_and_feedbacks]
  before_action :set_volunteer, only: [:find_client]
  before_action :set_client, only: [:find_volunteer]

  def index
    authorize Assignment
    @q = policy_scope(Assignment).ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @assignments = @q.result
    respond_to do |format|
      format.xlsx
      format.html do
        @assignments = @assignments.paginate(page: params[:page],
          per_page: params[:print] && @assignments.size)
      end
    end
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
    authorize @assignment
    if @assignment.save
      @assignment.client.update(state: Client::RESERVED)
      redirect_to assignments_url, make_notice
    else
      render :new
    end
  end

  def update
    if @assignment.update(assignment_params)
      update_redirect
    else
      render :edit
    end
  end

  def destroy
    @assignment.destroy.client.update(state: Client::REGISTERED)
    redirect_to assignments_url, make_notice
  end

  def find_volunteer
    @q = policy_scope(Volunteer).seeking_clients.ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @seeking_clients = @q.result.paginate(page: params[:page])
  end

  def find_client
    @q = policy_scope(Client).need_accompanying.ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @need_accompanying = @q.result.paginate(page: params[:page])
  end

  def last_submitted_hours_and_feedbacks
    @last_submitted_hours = @assignment.hours_since_last_submitted
    @last_submitted_feedbacks = @assignment.feedbacks_since_last_submitted
  end

  private

  def update_redirect
    if request.referer.include?('last_submitted_hours_and_feedbacks')
      redirect_to last_submitted_hours_and_feedbacks_assignment_path,
        notice: 'Die Stunden und Feedbacks wurden erfolgreich bestätigt.'
    else
      redirect_to(volunteer? ? @assignment.volunteer : assignments_url, make_notice)
    end
  end

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
      :first_instruction_lesson, :submitted_at)
  end
end
