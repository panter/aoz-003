class EmailTemplatesController < ApplicationController
  before_action :set_email_template, only: [:show, :edit, :update, :destroy]

  def index
    authorize EmailTemplate
    @email_templates = EmailTemplate.order_by_active
  end

  def show; end

  def new
    @email_template = EmailTemplate.new
    authorize @email_template
  end

  def edit; end

  def create
    @email_template = EmailTemplate.new(email_template_params)
    authorize @email_template
    if @email_template.save
      redirect_to @email_template, make_notice
    else
      render :new
    end
  end

  def update
    if @email_template.update(email_template_params)
      redirect_to @email_template, make_notice
    else
      render :edit
    end
  end

  def destroy
    @email_template.destroy
    redirect_to email_templates_url, make_notice
  end

  private

  def set_email_template
    @email_template = EmailTemplate.find(params[:id])
    authorize @email_template
  end

  def email_template_params
    params.require(:email_template).permit(:subject, :body, :kind, :active)
  end
end
