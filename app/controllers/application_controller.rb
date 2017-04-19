class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  def after_sign_in_path_for(current_user)
    if current_user.profile.blank?
      new_profile_path
    else
      root_path
    end
  end
end
