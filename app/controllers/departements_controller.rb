class DepartementsController < ApplicationController
  before_action :set_departement, only: [:show, :edit, :update, :destroy]

  def index
    @departements = Departement.all
  end

  def show; end

  def new
    @departement = Departement.new
  end

  def edit; end

  def create
    @departement = Departement.new(departement_params)
    respond_to do |format|
      if @departement.save
        format.html do
          redirect_to @departement, notice: 'Departement was successfully created.'
        end
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @departement.update(departement_params)
        format.html do
          redirect_to @departement, notice: 'Departement was successfully updated.'
        end
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @departement.destroy
    respond_to do |format|
      format.html do
        redirect_to departements_url, notice: 'Departement was successfully destroyed.'
      end
    end
  end

  private

  def set_departement
    @departement = Departement.find(params[:id])
  end

  def departement_params
    params.require(:departement).permit(:name, :street, :zip, :place, :phone, :email, :user_id)
  end
end
