class ListResponsesController < ApplicationController
  def feedbacks
    authorize :list_response, :feedbacks?
    @feedbacks = Feedback.all
  end

  def hours
    authorize :list_response, :hours?
    @hours = Hour.all
  end
end
