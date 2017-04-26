class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  def index
    @clients = Client.all
  end

  def show
  end

  def new
    @client = Client.new(user: current_user)
    @client.schedules << Schedule.build
  end

  def edit
  end

  def create
    @client = Client.new(client_params)
    respond_to do |format|
      if @client.save!
        format.html { redirect_to @client, notice: 'Client was successfully created.' }
        format.json { render :show, status: :created, location: @client }
      else
        format.html { render :new }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to @client, notice: 'Client was successfully updated.' }
        format.json { render :show, status: :ok, location: @client }
      else
        format.html { render :edit }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @client.destroy
    respond_to do |format|
      format.html { redirect_to clients_url, notice: 'Client was successfully destroyed.' }
      format.json { head :no_content }
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
                                      :lastname, :dob, :relation, :_destroy]
                                      )
    end
end
