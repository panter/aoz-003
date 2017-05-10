class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]
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
        @user.invite!
        format.html { redirect_to users_path, notice: t('invite_sent', email: @user.email) }
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
        format.html { redirect_to @user, notice: t('profile_updated') }
      else
        format.html { render :edit }
      end
    end
    authorize @user
  end

  def destroy
    authorize @user
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: t('user_destroyed') }
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
