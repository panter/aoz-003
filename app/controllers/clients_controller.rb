class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  def index
    @clients = policy_scope(Client)
  end

  def show
    authorize @client
  end

  def new
    @client = Client.new(user: current_user)
    @client.schedules << Schedule.build
    authorize @client
  end

  def edit
    authorize @client
  end

  def create
    @client = Client.new(client_params)
    @client.user = current_user
    respond_to do |format|
      if @client.save
        format.html { redirect_to @client, notice: t('.success') }
      else
        format.html { render :new }
      end
    end
    authorize @client
  end

  def update
    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to @client, notice: t('.success') }
      else
        format.html { render :edit }
      end
    end
    authorize @client
  end

  def destroy
    @client.destroy
    respond_to do |format|
      format.html { redirect_to clients_url, notice: t('.success') }
    end
    authorize @client
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(
      :id, :first_name, :last_name, :date_of_birth, :nationality, :permit, :gender,
      :street, :zip, :city, :phone, :email, :goals, :education, :hobbies,
      :interests, :state, :comments, :competent_authority, :involved_authority, :user_id,
      language_skills_attributes: [
        :id, :language, :level, :_destroy
      ],
      relatives_attributes: [
        :id, :first_name, :last_name, :date_of_birth, :relation, :_destroy
      ],
      schedules_attributes: [
        :id, :day, :time, :available
      ]
    )
  end
end
