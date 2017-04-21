class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]

  def index
    @users = User.all
  end

  def show; end

  def new
    @user = User.new
  end

  def edit; end

  def create
    @user = User.new user_params.merge(password: Devise.friendly_token)
    respond_to do |format|
      if @user.save
        @user.invite!
        format.html { redirect_to users_path, notice: "Invitation sent to #{@user.email}" }
      else
        format.html { render :new }
      end
    end
  end

  # only used to update the current user
  def update
    respond_to do |format|
      if @user.update(user_params)
        bypass_sign_in @user
        format.html { redirect_to @user, notice: 'Profile was successfully updated.' }
      else
        format.html { render :edit }
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
