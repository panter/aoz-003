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
    authorize @feedback
    simple_form_params
  end

  def edit
    simple_form_params
  end

  def create
    @feedback = Feedback.new(feedback_params.merge(author_id: current_user.id,
      volunteer_id: @volunteer.id))
    @feedback.feedbackable = @feedbackable
    authorize @feedback
    simple_form_params
    if @feedback.save
      redirect_to default_redirect || @volunteer, make_notice
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
    redirect_path = list_responses_feedbacks_path(params.to_unsafe_hash.slice(:q))
    if @feedback.update(reviewer: current_user)
      redirect_to(redirect_path, notice: 'Feedback als angeschaut markiert.')
    else
      redirect_to(redirect_path, notice: 'Fehler: Angeschaut markieren fehlgeschlagen.')
    end
  end

  private
  def simple_form_params
    @simple_form_for_params = [
      [@volunteer, @feedbackable, @feedback], {
        url: polymorphic_path(
          [@volunteer, @feedbackable, @feedback],
          redirect_to: default_redirect, group_assignment: params[:group_assignment]
        )
      }
    ]
  end

  def set_feedbackable
    @feedbackable = Assignment.find_by(id: params[:assignment_id]) ||
      GroupOffer.find_by(id: params[:group_offer_id])
  end

  def find_feedbackable_submit_form
    return @feedbackable if @feedbackable.assignment?
    GroupAssignment.find_by(id: params[:group_assignment])
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

  def feedback_params
    params.require(:feedback).permit(:goals, :achievements, :future, :comments, :conversation,
      :volunteer_id, :group_offer_id, :assignment_id)
  end
end
