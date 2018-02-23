class CertificatesController < ApplicationController
  before_action :set_certificate, only: [:show, :edit, :update, :destroy]
  before_action :set_volunteer

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
    @certificate = Certificate.new(volunteer: @volunteer, user_id: current_user.id)
    @certificate.build_values
    authorize @certificate
  end

  def edit; end

  def create
    @certificate = Certificate.new(prepare_params)
    authorize @certificate
    if @certificate.save
      redirect_to volunteer_certificate_path(@volunteer, @certificate)
    else
      render :new
    end
  end

  def update
    if @certificate.update(prepare_params)
      redirect_to volunteer_certificate_path(@volunteer, @certificate)
    else
      render :edit
    end
  end

  def destroy
    @certificate.destroy
    redirect_to volunteer_path(@volunteer)
  end

  private

  def prepare_params
    certificate_params
      .except(:assignment_kinds).merge(volunteer: @volunteer, user_id: current_user.id,
        assignment_kinds: { done: kinds_done_filter, available: kinds_available_filter })
  end

  def kinds_available_filter
    @kinds_available ||= GroupOfferCategory.where.not(id: kinds_done_filter
      .map { |done| done[1] }).map { |goc| [goc.category_name, goc.id] }
  end

  def kinds_done_filter
    @kinds_done ||= @volunteer.assignment_categories_done.select do |_, id|
      certificate_params[:assignment_kinds].reject(&:blank?).map(&:to_i).include? id
    end + @volunteer.assignment_categories_available.select do |_, id|
      certificate_params[:assignment_kinds].reject(&:blank?).map(&:to_i).include? id
    end
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
      :function, :volunteer_id, volunteer_contact: [:name, :street, :city], assignment_kinds: []
    )
  end
end
