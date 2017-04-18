class UsersController < ApplicationController
  before_action :set_current_user, only: [:show, :edit, :update]
  after_action :verify_authorized

  def index
    @users = User.all
    authorize User
  end

  def show
    authorize @user
  end

  def new
    @user = User.new
    authorize @user
  end

  def edit
    authorize @user
  end

  def create
    @user = User.new user_params.merge(password: Devise.friendly_token)
    respond_to do |format|
      if @user.save
        @user.send_reset_password_instructions
        format.html { redirect_to users_path, notice: "Invitation sent to #{@user.email}" }
      else
        format.html { render :new }
      end
    end
    authorize @user
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
    authorize @user
  end

  private

  def set_current_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:email, :password, :role)
  end
end
