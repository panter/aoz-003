class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(secure_params)
    if @user.save
      @user.confirm
      @user.send_reset_password_instructions
      flash[:notice] = "Invitation sent to #{@user.email}"
    end
    render 'new'
  end

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def secure_params
    params.require(:user).permit(:id, :email, :password, :password_confirmation, :role)
  end
end
