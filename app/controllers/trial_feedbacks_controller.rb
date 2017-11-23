class TrialFeedbacksController < ApplicationController
  before_action :set_trial_feedback, only: [:show, :edit, :update, :destroy]
  before_action :set_feedbackable
  before_action :set_volunteer

  def index
    authorize TrialFeedback
    @trial_feedbacks = policy_scope(TrialFeedback).where(feedbackable: @feedbackable)
  end

  def show; end

  def new
    @trial_feedback = TrialFeedback.new(feedbackable: @feedbackable, volunteer: @volunteer,
      author: current_user)
    authorize @trial_feedback
  end

  def edit; end

  def create
    @trial_feedback = TrialFeedback.new(trial_feedback_params.merge(author_id: current_user.id,
      volunteer_id: @volunteer.id))
    @trial_feedback.feedbackable = @feedbackable
    authorize @trial_feedback
    if @trial_feedback.save
      redirect_to @trial_feedback.volunteer, make_notice
    else
      render :new
    end
  end

  def update
    if @trial_feedback.update(feedback_params
        .merge(reviewer_id: current_user.superadmin? ? current_user.id : nil))
      redirect_to @trial_feedback.volunteer, make_notice
    else
      render :edit
    end
  end

  def destroy
    @trial_feedback.destroy
    redirect_back(fallback_location: url_for(@feedbackable))
  end

  private

  def set_feedbackable
    return @feedbackable = Assignment.find(params[:assignment_id]) if params[:assignment_id]
    @feedbackable = GroupOffer.find(params[:group_offer_id]) if params[:group_offer_id]
  end

  def set_volunteer
    @volunteer = Volunteer.find(params[:volunteer_id]) if params[:volunteer_id]
  end

  def set_trial_feedback
    @trial_feedback = TrialFeedback.find(params[:id])
    @feedbackable = @trial_feedback.feedbackable
    @volunteer = @trial_feedback.volunteer
    authorize @trial_feedback
  end

  def trial_feedback_params
    params.require(:trial_feedback).permit(:body, :volunteer_id, :group_offer_id, :assignment_id)
  end
end
