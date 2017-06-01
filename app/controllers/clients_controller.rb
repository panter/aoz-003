class ClientsController < ApplicationController
  include NestedAttributes

  before_action :set_client, only: [:show, :edit, :update, :destroy]

  def index
    @clients = policy_scope(Client)
  end

  def show; end

  def new
    @client = Client.new(user: current_user)
    @client.schedules << Schedule.build
    authorize @client
  end

  def edit; end

  def create
    @client = Client.new(client_params)
    @client.user = current_user
    authorize @client
    if @client.save
      redirect_to @client, notice: t('client_created')
    else
      render :new
    end
  end

  def update
    if @client.update(client_params)
      redirect_to @client, notice: t('client_updated')
    else
      render :edit
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_url, notice: t('client_destroyed')
  end

  private

  def set_client
    @client = Client.find(params[:id])
    authorize @client
  end

  def client_params
    params.require(:client).permit(:id, :first_name, :last_name, :date_of_birth, :nationality,
      :permit, :gender, :street, :zip, :city, :phone, :email, :goals, :education, :hobbies,
      :interests, :state, :comments, :competent_authority, :involved_authority, :user_id,
      language_skills_attributes: language_skills_attributes,
      relatives_attributes: relatives_attributes,
      schedules_attributes: schedules_attributes)
  end
end
