class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :destroy]

  def index
    @assignments = Assignment.all
  end

  def show; end

  def new
    @assignment = Assignment.new
  end

  def edit; end

  def create
    @assignment = Assignment.new(assignment_params)

    doc_pdf = WickedPdf.new.pdf_from_string(
      render_to_string(
        'assignments/show',
        layout: 'layouts/pdf',
        page_size: 'A4',
        locals: { assignment: @assignment }
      )
    )

    # save PDF to disk
    pdf_path = Rails.root.join('tmp', "#{Date.current.iso8601}.pdf")
    File.open(pdf_path, 'wb') do |file|
      file << doc_pdf
    end

    @assignment.agreement = File.open pdf_path

    if @assignment.save
      redirect_to(assignments_url, notice: 'Assignment was successfully created.')

      File.delete(pdf_path) if File.exist?(pdf_path)
    else
      render :new
    end
  end

  def update
    if @assignment.update(assignment_params)
      redirect_to assignments_url, notice: 'Assignment was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @assignment.destroy
    redirect_to assignments_url, notice: 'Assignment was successfully destroyed.'
  end

  private

  def set_assignment
    @assignment = Assignment.find(params[:id])
  end

  def assignment_params
    params.require(:assignment).permit(:client_id, :volunteer_id)
  end
end
