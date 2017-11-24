class ClientNotificationsController < ApplicationController
  before_action :set_client_notification, only: [:edit, :update, :destroy]

  def index
    authorize ClientNotification
    @client_notifications = ClientNotification.all
  end

  def new
    @client_notification = ClientNotification.new
    authorize @client_notification
  end

  def edit; end

  def create
    @client_notification = ClientNotification.new(client_notification_params)
    @client_notification.user = current_user
    authorize @client_notification
    if @client_notification.save
      redirect_to client_notifications_path, make_notice
    else
      render :new
    end
  end

  def update
    if @client_notification.update(client_notification_params)
      redirect_to client_notifications_path, make_notice
    else
      render :edit
    end
  end

  def destroy
    @client_notification.destroy
    redirect_to client_notifications_url, make_notice
  end

  private

  def set_client_notification
    @client_notification = ClientNotification.find(params[:id])
    authorize @client_notification
  end

  def client_notification_params
    params.require(:client_notification).permit(:body, :user_id, :active)
  end
end
