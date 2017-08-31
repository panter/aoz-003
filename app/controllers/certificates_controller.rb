class CertificatesController < ApplicationController
  before_action :set_certificate, only: [:show, :destroy]
  before_action :set_volunteer, except: [:edit, :show, :destroy]

  def index
    @certificates = Certificate.where(volunteer: @volunteer)
    authorize Certificate
  end

  def show
    respond_to do |format|
      format.docx { headers['Content-Disposition'] = 'attachment; filename="caracal.docx"' }
    end
  end

  def new
    @certificate = Certificate.new
    authorize @certificate
  end

  def create
    @certificate = Certificate.new(certificate_params.merge(volunteer_id: @volunteer.id))
    @certificate.user = current_user
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

  def set_certificate
    @certificate = Certificate.find(params[:id])
    @volunteer = @certificate.volunteer
    authorize @certificate
  end

  def set_volunteer
    @volunteer = Volunteer.find(params[:volunteer_id])
  end

  def certificate_params
    # params.require(:certificate).permit(
    #   :institution, :function, :mission, :period, :duration, :description, :creator_details,
    #   :user_id, :volunteer_id
    # )
    params.permit(
      :institution, :function, :mission, :period, :duration, :description, :creator_details,
      :user_id, :volunteer_id
    )
  end
end
