class HoursController < ApplicationController
  before_action :set_hour, only: [:show, :edit, :update, :destroy]

  def index
    authorize Hour
    @hours = policy_scope(Hour)
  end

  def show; end

  def new
    @hour = Hour.new
    authorize @hour
  end

  def edit; end

  def create
    @hour = Hour.new(hour_params)
    authorize @hour
    respond_to do |format|
      if @hour.save!
        format.html { redirect_to @hour, notice: 'Hour was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @hour.update(hour_params)
        format.html { redirect_to @hour, notice: 'Hour was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @hour.destroy
    respond_to do |format|
      format.html { redirect_to hours_url, notice: 'Hour was successfully destroyed.' }
    end
  end

  private

  def set_hour
    @hour = Hour.find(params[:id])
    authorize @hour
  end

  def hour_params
    params.require(:hour).permit(:meeting_date, :duration, :activity, :comments, :volunteer_id,
      :assignment_id)
  end
end
