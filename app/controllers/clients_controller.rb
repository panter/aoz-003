class ClientsController < ApplicationController
  include NestedAttributes

  before_action :set_client, only: [:show, :edit, :update, :destroy]

  def index
    @clients = policy_scope(Client)
  end

  def show
    authorize @client
  end

  def new
    @client = Client.new(user: current_user)
    @client.build_person
    # @client.schedules << Schedule.build
    authorize @client
  end

  def edit
    authorize @client
  end

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
    authorize @client
    if @client.update(client_params)
      redirect_to @client, notice: t('client_updated')
    else
      render :edit
    end
  end

  def destroy
    authorize @client
    @client.destroy
    redirect_to clients_url, notice: t('client_destroyed')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_client
    @client = Client.find(params[:id])
  end

  def relatives_attributes
    {
      relatives_attributes: [
        :id, :first_name, :last_name, :date_of_birth, :relation, :_destroy
      ]
    }
  end

  def schedules_attributes
    { schedules_attributes: [:id, :day, :time, :available] }
  end

  def language_skills_attributes
    { language_skills_attributes: [:id, :language, :level, :_destroy] }
  end

  def contact_point_attrs
    [:id, :body, :label, :_destroy, :type, :contacts_id]
  end

  def contacts_attributes
    { contact_attributes: [
      :street, :postal_code, :city, contact_emails_attributes: contact_point_attrs,
                                    contact_phones_attributes: contact_point_attrs
    ] }
  end

  def person_attributes
    { person_attributes: [
      :first_name, :last_name, :date_of_birth, :gender, :education, :hobbies, :interests,
      :nationality, language_skills_attributes, schedules_attributes, relatives_attributes,
      contacts_attributes
    ] }
  end

  def client_attributes
    [:id, :permit, :goals, :state, :comments, :competent_authority, :involved_authority, :user_id,
     person_attributes]
  end

  def client_params
    params.require(:client).permit(client_attributes)
  end
end
