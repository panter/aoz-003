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
      redirect_to client_notifications_path,
        notice: t('crud.created', model: human_model_name)
    else
      render :new
    end
  end

  def update
    if @client_notification.update(client_notification_params)
      redirect_to client_notifications_path, notice: t('crud.updated', model: human_model_name)
    else
      render :edit
    end
  end

  def destroy
    @client_notification.destroy
    redirect_to client_notifications_url, notice: t('crud.destroyed', model: human_model_name)
  end

  private

  def set_client_notification
    @client_notification = ClientNotification.find(params[:id])
    authorize @client_notification
  end

  def human_model_name
    @client_notification.class.model_name.human
  end

  def client_notification_params
    params.require(:client_notification).permit(:body, :user_id, :active)
  end
end
