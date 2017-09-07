class CertificatesController < ApplicationController
  before_action :set_certificate, only: [:show, :destroy, :update, :edit]
  before_action :set_volunteer, except: [:edit, :show, :destroy]

  def index
    @certificates = Certificate.where(volunteer: @volunteer)
    authorize Certificate
  end

  def show
    respond_to do |format|
      format.html { render :show }
    end
  end

  def new
    @certificate = Certificate.new(volunteer_id: @volunteer.id, user_id: current_user.id)
    authorize @certificate
  end

  def create
    @certificate = Certificate.new(certificate_params.merge(volunteer_id: @volunteer.id,
      user_id: current_user.id))
    @certificate.assignment_kinds = assignment_kinds
    @certificate.text_body = certificate_params['text_body']
    authorize @certificate
    if @certificate.save
      redirect_to volunteer_certificate_path(@volunteer, @certificate)
    else
      render :new
    end
  end

  def edit; end

  def update
    @certificate.update(certificate_params.merge(volunteer_id: @volunteer.id,
      user_id: current_user.id))
    @certificate.assignment_kinds = assignment_kinds
    @certificate.text_body = certificate_params['text_body']
    authorize @certificate
    if @certificate.save
      redirect_to volunteer_certificate_path(@volunteer, @certificate)
    else
      render :new
    end
  end

  def destroy
    @certificate.destroy
    redirect_to volunteer_path(@volunteer)
  end

  private

  def assignment_kinds
    certificate_params['assignment_kinds']
      .to_h
      .map { |key, bool| [key.to_sym, bool.to_i == 1] }
      .to_h
  end

  def set_certificate
    @certificate = Certificate.find(params[:id])
    @volunteer = @certificate.volunteer
    authorize @certificate
  end

  def set_volunteer
    @volunteer = Volunteer.find(params[:volunteer_id])
  end

  def certificate_params
    params.require(:certificate).permit(
      :duration, :duration_end, :duration_start, :hours, :minutes, :text_body,
      assignment_kinds: Assignment::KINDS
    )
  end
end
