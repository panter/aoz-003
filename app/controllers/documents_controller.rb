class DocumentsController < ApplicationController
  before_action :find_document, only: %i[update edit destroy]

  def new
    @document = Document.new
    authorize @document
  end

  def index
    authorize Document
    @documents_json = DocumentTreeview.new.document_js_nodes
  end

  def create
    @document = Document.create(document_params)
    authorize @document
    if @document.valid?
      redirect_to documents_path
    else
      render :new
    end
  end

  def edit; end

  def update
    @document.update(document_params)
    if @document.valid?
      redirect_to documents_path
    else
      render :edit
    end
  end

  def destroy
    @document.destroy
    redirect_to documents_path
  end

  private

  def find_document
    @document = Document.find(params[:id])
    authorize @document
  end

  def document_params
    params.require(:document).permit(
      :category1, :category2, :category3, :category4, :title, :file
    )
  end
end