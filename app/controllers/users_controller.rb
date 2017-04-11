class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update]

  def index
    @users = User.all
  end

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.merge(password: Devise.friendly_token))
    respond_to do |format|
      if @user.save
        @user.send_reset_password_instructions
        format.html { redirect_to users_path, notice: "Invitation sent to #{@user.email}" }
      else
        format.html { render :new }
      end
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :role)
  end
end
