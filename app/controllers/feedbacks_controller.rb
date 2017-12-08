class FeedbacksController < ApplicationController
  before_action :set_feedback, only: [:show, :edit, :update, :destroy, :mark_as_done]
  before_action :set_feedbackable
  before_action :set_volunteer

  def index
    authorize Feedback
    @feedbacks = policy_scope(Feedback).where(feedbackable: @feedbackable)
  end

  def show; end

  def new
    @feedback = Feedback.new(feedbackable: @feedbackable, volunteer: @volunteer,
      author: current_user)
    session[:request_url] = request.referer
    authorize @feedback
  end

  def edit; end

  def create
    @feedback = Feedback.new(feedback_params.merge(author_id: current_user.id,
      volunteer_id: @volunteer.id))
    @feedback.feedbackable = @feedbackable
    authorize @feedback
    if @feedback.save
      redirect_to create_redirect, make_notice
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

  def mark_as_done
    if @feedback.update(marked_done_by: current_user)
      redirect_to list_responses_feedbacks_path, notice: 'Feedback als erledigt markiert.'
    else
      redirect_to list_responses_feedbacks_path, notice: 'Fehler: Erledigt markieren fehlgeschlagen.'
    end
  end

  private

  def set_feedbackable
    return @feedbackable = Assignment.find(params[:assignment_id]) if params[:assignment_id]
    @feedbackable = GroupOffer.find(params[:group_offer_id]) if params[:group_offer_id]
  end

  def set_volunteer
    @volunteer = Volunteer.find(params[:volunteer_id]) if params[:volunteer_id]
  end

  def set_feedback
    @feedback = Feedback.find(params[:id])
    @feedbackable = @feedback.feedbackable
    @volunteer = @feedback.volunteer
    authorize @feedback
  end

  def create_redirect
    if !session[:request_url].include?('last_submitted_hours_and_feedbacks')
      @volunteer
    elsif @feedback.assignment?
      last_submitted_hours_and_feedbacks_assignment_path(@feedbackable)
    else
      group_assignment = @feedbackable.group_assignments.where(volunteer: @volunteer).last
      last_submitted_hours_and_feedbacks_group_assignment_path(group_assignment)
    end
  end

  def feedback_params
    params.require(:feedback).permit(:goals, :achievements, :future, :comments, :conversation,
      :volunteer_id, :group_offer_id, :assignment_id)
  end
end
