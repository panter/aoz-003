class ClientsController < ApplicationController
  include NestedAttributes
  include ContactAttributes
  include MakeNotice

  before_action :set_client, only: [:show, :edit, :update, :destroy]

  def index
    @clients = policy_scope(Client)
  end

  def show; end

  def new
    @client = Client.new(user: current_user)
    @client.schedules << Schedule.build
    @client.build_contact
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

  def without_assignments
    @without_assignments = Client.without_assignments
  end

  private

  def set_client
    @client = Client.find(params[:id])
    authorize @client
  end

  def client_params
    params.require(:client).permit(
      :entry_year, :gender_request, :age_request, :other_request, :date_of_birth,
      :gender, :nationality, :permit, :goals, :education, :interests,
      :state, :comments, :involved_authority, :competent_authority, :actual_activities,
      language_skills_attributes, relatives_attributes, schedules_attributes,
      contact_attributes
      )
  end
end
