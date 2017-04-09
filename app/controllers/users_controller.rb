class UsersController < ApplicationController

  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update_password
    @user = User.find(current_user.id)
    pw_update_result = @user.update_with_password(user_params)
    respond_to do |format|
      return render :edit unless pw_update_result
      @user.send_password_change_notification
      # Sign in the user by passing validation in case their password changed
      bypass_sign_in @user, scope: :user
      format.html { redirect_to @user.profile }
    end
  end

  def edit_email
    @user = current_user
  end

  def update_email
    @user = User.find(current_user.id)
    respond_to do |format|
      if @user.update(email_params)
        @user.send_email_changed_notification
        bypass_sign_in @user, scope: :user
        format.html { redirect_to @user.profile }
      else
        format.html { render :edit_email }
      end
    end

  end


  private

    def user_params
      # NOTE: Using `strong_parameters` gem
      params.require(:user).permit(:password, :password_confirmation, :current_password)
    end

    def email_params
      params.require(:user).permit(:email)
    end
end
