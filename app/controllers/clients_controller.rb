class ClientsController < ApplicationController
  include NestedAttributes
  include ContactAttributes
  include MakeNotice

  before_action :set_client, only: [:show, :edit, :update, :destroy]

  def index
    authorize Client
    @clients = policy_scope(Client).paginate(page: params[:page])
  end

  def show; end

  def new
    @client = Client.new(user: current_user)
    @client.build_schedules
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
    @need_accompanying = Client.need_accompanying
    @need_accompanying = @need_accompanying.paginate(page: params[:page])
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
      language_skills_attributes, relatives_attributes, schedules_attributes,
      contact_attributes
    )
  end
end
