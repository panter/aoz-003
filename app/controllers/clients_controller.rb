class ClientsController < ApplicationController
  include AvailabilityAttributes
  include NestedAttributes
  include ContactAttributes

  before_action :set_client, only: [:show, :edit, :update, :set_terminated]
  before_action :set_social_worker_collection, only: [:new, :edit]

  def index
    authorize Client
    @q = policy_scope(Client).ransack(params[:q])
    @q.sorts = ['acceptance asc'] if @q.sorts.empty?
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
    @client.language_skills.build(language: 'DE')
    authorize @client
  end

  def edit
    @client.language_skills.build(language: 'DE') if @client.german_missing?
  end

  def create
    @client = Client.new(client_params)
    @client.user = current_user
    @client.involved_authority ||= current_user if current_user.social_worker?
    authorize @client
    if @client.save
      redirect_to @client, create_success_notice
    else
      render :new
    end
  end

  def update
    @client.assign_attributes(client_params)
    @client.resigned_by = current_user if @client.will_save_change_to_acceptance?(to: :resigned)
    if @client.save
      redirect_to @client, create_update_redirect_notice
    else
      @custom_notice = resigned_fail_notice if @client.errors.messages[:acceptance].present?
      render :edit
    end
  end

  def set_terminated
    if @client.update(acceptance: :resigned, resigned_by: current_user)
      redirect_back(fallback_location: client_path(@client),
        notice: 'Klient/in wurde erfolgreich beendet.')
    else
      redirect_back(fallback_location: client_path(@client), notice: resigned_fail_notice)
    end
  end

  private

  def create_success_notice
    if @client.user.social_worker? && ClientNotification.active.any?
      { notice: ClientNotification.active.pluck(:body).to_sentence }
    else
      make_notice
    end
  end

  def create_update_redirect_notice
    if @client.saved_change_to_acceptance?(to: :resigned)
      { notice: 'Klient/in wurde erfolgreich beendet.' }
    else
      make_notice
    end
  end

  def resigned_fail_notice
    {
      message: 'Beenden fehlgeschlagen.', model_message: @client.errors.messages[:acceptance].first,
      action_link: { text: 'Begleitung bearbeiten', path: edit_assignment_path(@client.assignment) }
    }
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
      :gender_request, :age_request, :other_request, :birth_year, :salutation,
      :nationality, :entry_date, :permit, :goals, :education, :interests, :acceptance,
      :comments, :additional_comments, :involved_authority_id, :competent_authority,
      :actual_activities, :cost_unit, language_skills_attributes, relatives_attributes,
      contact_attributes, availability_attributes
    )
  end
end
