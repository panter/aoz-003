class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(
      email: secure_params[:email],
      role: secure_params[:role],
      password: Devise.friendly_token
    )
    return render :new unless @user.save
    @user.send_reset_password_instructions
    flash[:notice] = "Invitation sent to #{@user.email}"
  end

  def edit_password
    @user = current_user
  end

  def update_password
    return render :edit unless current_user.update_with_password(password_params)
    respond_to do |format|
      current_user.send_password_change_notification
      flash[:notice] = "Password change email has been sent to #{current_user.email}"
      bypass_sign_in current_user, scope: :user
      format.html { redirect_to current_user.profile }
    end
  end

  def edit_email
    @user = current_user
  end

  def update_email
    return render :edit_email unless current_user.update(email_params)
    respond_to do |format|
      current_user.send_email_changed_notification
      flash[:notice] = "Email changed email has been sent to #{current_user.email}"
      bypass_sign_in current_user, scope: :user
      format.html { redirect_to current_user.profile }
    end
  end

  def index
    @users = User.all
  end

  private

  def create_params
    params.require(:user).permit(:email, :role, :password)
  end

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
