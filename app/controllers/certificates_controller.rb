class CertificatesController < ApplicationController
  before_action :set_certificate, only: [:show, :destroy, :update, :edit]
  before_action :set_volunteer, except: [:edit, :show, :destroy]

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
    @certificate.update(assignment_kinds: assignment_kinds,
      text_body: certificate_params['text_body'],
      volunteer_contact: certificate_params['volunteer_contact'],
      institution: certificate_params['institution'])
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
      :duration, :duration_end, :duration_start, :hours, :minutes, :text_body, :institution,
      :function, volunteer_contact: [:name, :street, :city], assignment_kinds: Assignment::KINDS
    )
  end
end
