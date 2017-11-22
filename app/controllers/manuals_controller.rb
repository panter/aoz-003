class ManualsController < ApplicationController
  before_action :set_manual, only: [:edit, :update, :destroy]

  def index
    authorize Manual
    @manuals = Manual.all
  end

  def new
    @manual = Manual.new
    authorize @manual
  end

  def edit; end

  def create
    @manual = Manual.new(manual_params)
    @manual.user = current_user
    authorize @manual
    if @manual.save
      redirect_to manuals_url, make_notice
    else
      render :new
    end
  end

  def update
    if @manual.update(manual_params)
      redirect_to manuals_url, make_notice
    else
      render :edit
    end
  end

  def destroy
    @manual.destroy
    redirect_to manuals_url, make_notice
  end

  private

  def set_manual
    @manual = Manual.find(params[:id])
    authorize @manual
  end

  def manual_params
    params.require(:manual).permit(:title, :description, :category, :attachment, :attachment_file_name, :user_id)
  end
end
