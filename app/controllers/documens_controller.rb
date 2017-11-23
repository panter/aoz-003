class DocumentsController < ApplicationController

  def index
    @documents_json = DocumentTreeview.new.document_js_nodes
    respond_with @documents
  end

  def create
    @document = Document.create(document_params)
    if @document.valid?
      redirect_to action: :index
    else
      render :new
    end
  end

  private

  def document_params
    params.require(:document).permit(
      :category0, :category1, :category2, :category3, :title, :attachment
    )
  end
end
