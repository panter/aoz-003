class FeedbacksController < ApplicationController
  before_action :set_feedback,
    only: [:show, :edit, :update, :destroy, :mark_as_done, :take_responsibility]
  before_action :set_feedbackable, except: [:index]
  before_action :set_volunteer
  before_action :set_list_response_feedback_redirect_back_path,
    only: [:mark_as_done, :take_responsibility]

  def index
    authorize Feedback
    @feedbacks = if params[:assignment_id]
                   SemesterFeedback.where(assignment_id: params[:assignment_id])
                 elsif params[:group_offer_id]
                   SemesterFeedback.where(group_assignment_id: GroupAssignment.where(group_offer_id: params[:group_offer_id]).ids)
                 else
                  []
                 end
  end

  def show; end

  def new
    @feedback = SemesterFeedback.new(feedbackable: @feedbackable, volunteer: @volunteer,
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
      redirect_to params[:redirect_to] || @feedback.volunteer, make_notice
    else
      render :edit
    end
  end

  def destroy
    @feedback.destroy
    redirect_back(fallback_location: url_for(@feedbackable))
  end

  def mark_as_done
    respond_to do |format|
      if @feedback.update(reviewer: current_user)
        format.html { redirect_to(@redirect_back_path, notice: 'Halbjahres-Rapport quittiert.') }
        format.json { render json: { link: polymorphic_path([@feedback.volunteer, @feedback.feedbackable, @feedback]) }, status: :ok }
      else
        format.html { redirect_to(@redirect_back_path, notice: 'Fehler: Quittieren fehlgeschlagen.') }
        format.json { render json: { errors: @feedback.errors.messages }, status: :unprocessable_entity }
      end
    end
  end

  def take_responsibility
    respond_to do |format|
      if @feedback.update(responsible: current_user)
        format.html { redirect_to(@redirect_back_path, notice: 'Halbjahres-Rapport übernommen.') }
        format.json do
          render json: { link: url_for(@feedback.responsible), at: I18n.l(@feedback.responsible_at.to_date),
                         email: @feedback.responsible.email }, status: :ok
        end
      else
        format.html { redirect_to(@redirect_back_path, notice: 'Fehler: Übernehmen fehlgeschlagen.') }
        format.json { render json: { errors: @feedback.errors.messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_list_response_feedback_redirect_back_path
    @redirect_back_path = list_responses_feedbacks_path(
      params.to_unsafe_hash.slice(:q, :page)
    )
  end

  def simple_form_params
    @simple_form_for_params = [
      [@volunteer, @feedbackable, @feedback], {
        url: polymorphic_path(
          [@volunteer, @feedbackable, @feedback],
          redirect_to: params[:redirect_back] || default_redirect,
          group_assignment: params[:group_assignment]
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
