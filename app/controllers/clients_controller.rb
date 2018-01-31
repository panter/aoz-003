class ClientsController < ApplicationController
  include AvailabilityAttributes
  include NestedAttributes
  include ContactAttributes

  before_action :set_client, only: [:show, :edit, :update, :destroy, :set_resigned]
  before_action :set_social_worker_collection

  def index
    authorize Client
    @q = policy_scope(Client).ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @clients = @q.result
    respond_to do |format|
      format.xlsx
      format.html do
        @clients = @clients.paginate(page: params[:page], per_page: params[:print] && @clients.size)
      end
    end
  end

  def search
    authorize Client
    @q = policy_scope(Client).ransack contact_full_name_cont: params[:term]
    @clients = @q.result distinct: true
    respond_to do |format|
      format.json
    end
  end

  def show; end

  def new
    @client = Client.new(user: current_user)
    @client.language_skills << LanguageSkill.new(language: 'DE')
    authorize @client
  end

  def edit
    @client.language_skills << LanguageSkill.new(language: 'DE') if @client.german_missing?
  end

  def create
    @client = Client.new(client_params)
    @client.user = current_user
    @client.involved_authority ||= current_user if current_user.social_worker?
    authorize @client
    if @client.save
      if @client.user.social_worker? && ClientNotification.active.any?
        redirect_to @client, notice: ClientNotification.active.pluck(:body).to_sentence
      else
        redirect_to @client, make_notice
      end
    else
      render :new
    end
  end

  def update
    if @client.update(client_params)
      redirect_to @client, make_notice
    else
      render :edit
    end
  end

  def set_resigned
    if @client.update(acceptance: 'resigned')
      redirect_to @client, notice: 'Der klient wurde erfolgreich beendet.'
    else
      redirect_back(fallback_location: client_path(@client),
        notice: 'Der Klient konnte nicht beendet werden.')
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_url, make_notice
  end

  private

  end

  def set_client
    @client = Client.find(params[:id])
    authorize @client
  end

  def set_social_worker_collection
    @social_workers = User.social_workers
  end

  def client_params
    params.require(:client).permit(
      :gender_request, :age_request, :other_request, :birth_year,
      :salutation, :nationality, :entry_date, :permit, :goals, :education, :interests,
      :acceptance, :comments, :involved_authority_id, :competent_authority, :actual_activities,
      :cost_unit, language_skills_attributes, relatives_attributes, contact_attributes,
      availability_attributes
    )
  end
end
