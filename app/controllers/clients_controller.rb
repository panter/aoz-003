class ClientsController < ApplicationController
  include AvailabilityAttributes
  include NestedAttributes
  include ContactAttributes

  before_action :set_client, only: [:show, :edit, :update, :destroy]

  def index
    authorize Client
    @q = policy_scope(Client).ransack(params[:q])
    respond_to do |format|
      if params[:format] == 'xlsx'
        @clients = @q.result
        format.xlsx
      else
        @clients = @q.result.paginate(page: params[:page])
        format.html
      end
    end
  end

  def show; end

  def new
    @client = Client.new(user: current_user)
    authorize @client
  end

  def edit; end

  def create
    @client = Client.new(client_params)
    @client.user = current_user
    authorize @client
    if @client.save
      redirect_to @client, make_notice
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

  def destroy
    @client.destroy
    redirect_to clients_url, make_notice
  end

  def need_accompanying
    @q = Client.need_accompanying.ransack(params[:q])
    @need_accompanying = @q.result.paginate(page: params[:page])
    authorize @need_accompanying
  end

  private

  def set_client
    @client = Client.find(params[:id])
    authorize @client
  end

  def client_params
    params.require(:client).permit(
      :entry_year, :gender_request, :age_request, :other_request, :birth_year,
      :salutation, :nationality, :permit, :goals, :education, :interests,
      :state, :comments, :involved_authority, :competent_authority, :actual_activities,
      language_skills_attributes, relatives_attributes, contact_attributes,
      availability_attributes
    )
  end
end
