class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def index
    @users = User.all
    authorize User
  end

  def show
    @user = User.find(params[:id])
    authorize @user
  end

  def update
    @user = User.find(params[:id])
    authorize @user
    if @user.update_attributes(secure_params)
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end

  private

  def secure_params
    params.require(:user).permit(:id, :email, :password, :password_confirmation, :role)
  end
end
