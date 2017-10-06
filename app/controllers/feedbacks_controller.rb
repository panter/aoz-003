class FeedbacksController < ApplicationController
  before_action :set_feedback, only: [:show, :edit, :update, :destroy]
  before_action :set_assignment

  def index
    authorize Feedback
    @feedbacks = policy_scope(Feedback).where(assignment: @assignment)
  end

  def show; end

  def new
    @feedback = Feedback.new(assignment: @assignment,
      volunteer: @assignment.volunteer)
    authorize @feedback
  end

  def edit; end

  def create
    @feedback = Feedback.new(feedback_params
      .merge(author_id: current_user.id))
    authorize @feedback
    if @feedback.save
      redirect_to assignment_feedback_path(@assignment, @feedback), make_notice
    else
      render :new
    end
  end

  def update
    if @feedback.update(feedback_params)
      redirect_to assignment_feedback_path(@assignment, @feedback), make_notice
    else
      render :edit
    end
  end

  def destroy
    @feedback.destroy
    redirect_to assignment_feedbacks_path, make_notice
  end

  private

  def set_feedback
    @feedback = Feedback.find(params[:id])
    authorize @feedback
  end

  def set_assignment
    @assignment = Assignment.find(params[:assignment_id]) if params[:assignment_id]
  end

  def feedback_params
    params.require(:feedback).permit(:goals, :achievements, :future, :comments,
      :conversation, :assignment_id, :volunteer_id)
  end
end
