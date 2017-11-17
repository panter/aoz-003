class UsersController < ApplicationController
  include ContactAttributes

  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    authorize User
    @q = User.ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @users = @q.result
    respond_to do |format|
      format.html
      format.xlsx do
        render xlsx: 'index', filename: xlsx_filename
      end
    end
  end

  def show; end

  def new
    @user = User.new
    authorize @user
  end

  def edit; end

  def create
    @user = User.new user_params.merge(password: Devise.friendly_token)
    authorize @user
    if @user.save
      @user.invite!
      redirect_to users_path, notice: t('invite_sent', email: @user.email)
    else
      render :new
    end
  end

  # only used to update the current user
  def update
    if handle_update(user_params)
      bypass_sign_in @user if @user == current_user
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

  def xlsx_filename
    if params[:q] && User::ROLES.include?(params[:q][:role_eq])
      t("role.#{params[:q][:role_eq]}")
    else
      'Benutzer_Liste'
    end
  end

  def handle_update(user_params)
    if user_params[:password].blank?
      @user.update_without_password(user_params)
    else
      @user.update(user_params)
    end
  end

  def set_user
    @user = User.find(params[:id])
    authorize @user
  end

  def user_params
    params.require(:user).permit(:email, :password, :role,
      profile_attributes: [
        contact_attributes: contact_attributes[:contact_attributes]
      ])
  end
end
