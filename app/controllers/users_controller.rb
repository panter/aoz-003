class UsersController < ApplicationController
  include ContactAttributes
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized

  def index
    @users = User.all
    authorize User
  end

  def show; end

  def new
    @user = User.new
    @user.build_profile
    @user.profile.build_contact
    authorize @user
  end

  def edit; end

  def create
    @user = User.new user_params.merge(password: Devise.friendly_token)
    # this needs to be done to ensure department handling dont fail
    @user.build_profile
    @user.profile.build_contact(contact_params)
    @user.profile.contact.primary_email = @user.email

    if @user.save
      @user.invite!
      redirect_to users_path, notice: t('invite_sent', email: @user.email)
    else
      render :new
    end
    authorize @user
  end

  # only used to update the current user
  def update
    if @user.update(user_params)
      bypass_sign_in @user
      redirect_to @user, notice: t('profile_updated')
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: t('user_destroyed', email: @user.email)
  end

  private

  def set_user
    @user = User.find(params[:id])
    authorize @user
  end

  def user_params
    params.require(:user).permit(:email, :password, :role)
  end

  def contact_params
    params.require(:contact).permit(contact_attributes[:contact_attributes])
  end
end
