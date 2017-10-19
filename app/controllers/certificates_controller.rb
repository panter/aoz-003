class CertificatesController < ApplicationController
  before_action :set_certificate, except: [:index, :new]
  before_action :set_volunteer, only: [:index, :new]

  def index
    authorize Certificate
    @certificates = Certificate.where(volunteer: @volunteer)
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "volunteer_certificate_#{@certificate.id}", encoding: 'UTF-8',
          layout: 'certificate.pdf', page_size: 'A4', print_media_type: true, no_background: true,
          margin: { top: 0, bottom: 0, left: 0, right: 0 }
      end
    end
  end

  def new
    @certificate = Certificate.new(volunteer_id: @volunteer.id, user_id: current_user.id)
    @certificate.build_values
    authorize @certificate
  end

  def edit; end

  def create
    @certificate = Certificate.new(certificate_params.merge(volunteer_id: @volunteer.id,
      user_id: current_user.id))
    authorize @certificate
    if @certificate.save
      redirect_to volunteer_certificate_path(@volunteer, @certificate)
    else
      render :new
    end
  end

  def update
    if @certificate.update(certificate_params)
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
    params.require(:certificate).permit(
      :duration, :duration_end, :duration_start, :hours, :minutes, :text_body, :institution,
      :function, :group_offer, volunteer_contact: [:name, :street, :city],
      assignment_kinds: Assignment::KINDS
    )
  end
end
