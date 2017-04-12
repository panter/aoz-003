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

  def edit_password
    @user = current_user
  end

  def update_password
    @user = User.find(current_user.id)
    return render :edit unless @user.update_with_password(password_params)
    respond_to do |format|
      @user.send_password_change_notification
      bypass_sign_in @user, scope: :user
      format.html { redirect_to @user.profile }
    end
  end

  def edit_email
    @user = current_user
  end

  def update_email
    @user = User.find(current_user.id)
    return render :edit_email unless @user.update(email_params)
    respond_to do |format|
      @user.send_email_changed_notification
      bypass_sign_in @user, scope: :user
      format.html { redirect_to @user.profile }
    end
  end

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def email_params
    params.require(:user).permit(:email)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end

  def secure_params
    params.require(:user).permit(:id, :email, :password, :password_confirmation, :role)
  end
end
