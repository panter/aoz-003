class JournalsController < ApplicationController
  before_action :set_journaled
  before_action :set_journal, only: [:edit, :update, :destroy]

  def index
    authorize Journal
    @q = @journaled.journals.ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @journals = @q.result.paginate(page: params[:page])
  end

  def new
    @journal = @journaled.journals.new
    handle_semester_feedback_quote
    authorize @journal
  end

  def edit; end

  def create
    @journal = @journaled.journals.new(journal_params)
    @journal.user = current_user
    authorize @journal
    if @journal.save
      redirect_to [@journaled, Journal], make_notice
    else
      render :new
    end
  end

  def update
    if @journal.update(journal_params)
      redirect_to [@journaled, Journal], make_notice
    else
      render :edit
    end
  end

  def destroy
    @journal.destroy
    redirect_to [@journaled, Journal], make_notice
  end

  private

  def set_journal
    @journal = Journal.find_by(id: params[:id])
    if @journal
      authorize @journal
    else
      redirect_to @journaled, notice: t('crud.c_action.destroy', model: t_model)
    end
  end

  def set_journaled
    return @journaled = Client.find(params[:client_id]) if params[:client_id]
    @journaled = Volunteer.find(params[:volunteer_id])
  end

  def handle_semester_feedback_quote
    return unless params[:sp_volunteer_id]

    @journal.category = :feedback
    @semester_process_volunteer = SemesterProcessVolunteer.find(params[:sp_volunteer_id])
    @journal.journalable = @semester_process_volunteer.volunteer
    @journal.title = "Semester Prozess Feedback vom #{I18n.l(@semester_process_volunteer.created_at.to_date)}: "
  end

  def journal_params
    params.require(:journal).permit(
      :category, :user_id, :body, :title, :client_id, :volunteer_id
    )
  end
end
