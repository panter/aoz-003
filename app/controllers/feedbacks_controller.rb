class FeedbacksController < ApplicationController
  before_action :set_feedback, only: [:show, :edit, :update, :destroy]
  before_action :set_feedback_about

  def index
    authorize Feedback
    @feedbacks = policy_scope(Feedback).where(feedbackable: @assignment)
  end

  def show; end

  def new
    @feedback = Feedback.new(feedbackable: @feedback_about, volunteer: current_user.volunteer)
    authorize @feedback
  end

  def edit; end

  def create
    @feedback = Feedback.new(feedback_params.merge(author_id: current_user.id))
    authorize @feedback
    if @feedback.save
      redirect_to url_for([@feedback_about, @feedback]), make_notice
    else
      render :new
    end
  end

  def update
    if @feedback.update(feedback_params)
      redirect_to url_for([@feedback_about, @feedback]), make_notice
    else
      render :edit
    end
  end

  def destroy
    @feedback.destroy
    redirect_back(fallback_location: url_for(@feedback_about))
  end

  private

  def set_feedback
    @feedback = Feedback.find(params[:id])
    authorize @feedback
  end

  def set_feedback_about
    return @feedback_about = Assignment.find(params[:assignment_id]) if params[:assignment_id]
    return @feedback_about = GroupOffer.find(params[:group_offer_id]) if params[:group_offer_id]
    @feedback_about = nil
  end

  def feedback_params
    params.require(:feedback).permit(:goals, :achievements, :future, :comments, :conversation,
      :feedbackable_id, :feedbackable_type, :volunteer_id)
  end
end
