class JournalsController < ApplicationController

  before_action :set_journal, only: [:show, :edit, :update, :destroy]
  before_action :set_journaled

  def index
    authorize Journal
    @journals = Journal.where(journal_relations.except(:user_id))
  end

  def show; end

  def new
    @journal = Journal.new(journal_relations)
    authorize @journal
  end

  def edit; end

  def create
    @journal = Journal.new(journal_params.merge(journal_relations))
    authorize @journal
    if @journal.save
      redirect_to @journaled, make_notice
    else
      render :new
    end
  end

  def update
    if @journal.update(journal_params)
      redirect_to @journaled, make_notice
    else
      render :edit
    end
  end

  def destroy
    @journal.destroy
    redirect_to @journaled, make_notice
  end

  private

  def journal_relations
    {
      journalable_type: @journaled.class.model_name.name,
      journalable_id: @journaled.id,
      user_id: current_user.id
    }
  end

  def set_journal
    @journal = Journal.find(params[:id])
    authorize @journal
  end

  def set_journaled
    return @journaled = Client.find(params[:client_id]) if params[:client_id]
    @journaled = Volunteer.find(params[:volunteer_id])
  end

  def journal_params
    params.require(:journal).permit(
      :category, :subject, :user_id, :body, :client_id, :volunteer_id
    )
  end
end
