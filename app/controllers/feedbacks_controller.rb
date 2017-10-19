class FeedbacksController < ApplicationController
  before_action :set_feedback, only: [:show, :edit, :update, :destroy]
  before_action :set_feedbackable, only: [:new, :create]
  before_action :set_volunteer, only: [:new, :create]

  def index
    authorize Feedback
    @feedbacks = policy_scope(Feedback)
    if params[:group_offer_id]
      @feedbacks = @feedbacks.where(feedbackable_id: params[:group_offer_id])
      @volunteer = current_user.volunteer || @feedbacks.first.volunteer
    elsif params[:assignment_id]
      @feedbacks = @feedbacks.where(feedbackable_id: params[:assignment_id])
      @volunteer = Assignment.find(params[:assignment_id]).volunteer
    elsif params[:volunteer_id]
      @feedbacks = @feedbacks.where(volunteer_id: params[:volunteer_id])
      @volunteer = Volunteer.find(params[:volunteer_id])
    end
  end

  def show; end

  def new
    @feedback = Feedback.new(feedbackable: @feedbackable, volunteer: @volunteer,
      author: current_user)
    authorize @feedback
  end

  def edit; end

  def create
    @feedback = Feedback.new(feedback_params.merge(author_id: current_user.id))
    authorize @feedback
    if @feedback.save
      redirect_to @feedback.volunteer, make_notice
    else
      render :new
    end
  end

  def update
    if @feedback.update(feedback_params)
      redirect_to @feedback.volunteer, make_notice
    else
      render :edit
    end
  end

  def destroy
    @feedback.destroy
    redirect_back(fallback_location: url_for(@feedbackable))
  end

  private

  def set_feedbackable
    return @feedbackable = Assignment.find(params[:assignment_id]) if params[:assignment_id]
    return @feedbackable = GroupOffer.find(params[:group_offer_id]) if params[:group_offer_id]
    if params[:feedbackable_type] == 'GroupOffer'
      @feedbackable = GroupOffer.find(params[:feedbackable_id])
    end
  end

  def set_volunteer
    @volunteer = current_user.volunteer if current_user.volunteer?
    @volunteer ||= Volunteer.find(params[:volunteer_id]) if params[:volunteer_id]
    @volunteer ||= Volunteer.find(params[:volunteer]) if params[:volunteer]
    @volunteer ||= @feedbackable.volunteer if @feedbackable.class == Assignment
  end

  def set_feedback
    @feedback = Feedback.find(params[:id])
    @feedbackable = @feedback.feedbackable
    @volunteer = @feedback.volunteer
    authorize @feedback
  end

  def feedback_params
    params.require(:feedback).permit(:goals, :achievements, :future, :comments, :conversation,
      :feedbackable_id, :feedbackable_type, :volunteer_id, :feedbackable_id_and_type, :author_id,
      :volunteer)
  end
end
