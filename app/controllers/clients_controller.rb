class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  def index
    @clients = policy_scope(Client)
  end

  def show
    authorize @client
  end

  def new
    @client = Client.new
    authorize @client
  end

  def edit
    authorize @client
  end

  def create
    @client = Client.new(client_params)
    authorize @client
    @client.user = current_user
    respond_to do |format|
      if @client.save!
        format.html { redirect_to @client, notice: 'Client was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    authorize @client
    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to @client, notice: 'Client was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_client
    @client = Client.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def client_params
    params.require(:client).permit(:id, :firstname, :lastname, :dob, :nationality,
      :permit, :gender, :street, :zip, :city,
      :phone, :email, :goals, :education, :hobbies,
      :interests, :state, :comments, :c_authority,
      :i_authority, :availability,
      language_skills_attributes: [:id, :language,
                                   :level, :_destroy],
        relatives_attributes: [:id, :firstname,
                               :lastname, :dob, :relation, :_destroy])
  end
end
