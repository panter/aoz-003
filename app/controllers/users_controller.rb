class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(secure_params)
    if @user.save!
      @user.confirm
      @user.send_reset_password_instructions
      flash[:notice] = "Invitation sent to #{@user.email}"
      render 'new'
    else
      render 'new'
    end
  end

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(secure_params)
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end

  private

  def secure_params
    params.require(:user).permit(:id, :email, :role)
  end
end
