module ApiButtonHelper
  # api_button helper
  #
  # params:
  #   text - the links text (required)
  #   subject - polymorphic object array or single object (required) - [volunteer, assignment, feedback]
  #   action - the controller action for the subject (optional) - skip if its intended for update action
  #   class - additional classes to the bootstrap btn classes (optional) - string with space separated
  #   size - the bootstrap button size class (optional) - default 'btn-xs'
  #   button_type - bootstrap button type (optional) - default 'btn-default'
  #   data - hash containing extra data attributes
  #   template - string for being rendered with the data in the response - https://lodash.com/docs/4.17.10#template
  def api_button(text, params)
    tag.button(
      text,
      class: api_button_class(params),
      data: api_button_data(params)
    )
  end

  def api_button_class(params)
    extra_classes = params[:class]&.split(' ') || []
    button_type = params[:button_type] || 'btn-default'
    size = params[:size] || 'btn-xs'
    (['api-button', 'btn', size, button_type] + extra_classes).join(' ')
  end

  def api_button_data(params)
    {
      template: params[:template],
      method: params[:method]&.to_s&.upcase || :PUT,
      url: polymorphic_url(api_button_subject(params), action: params[:action] || nil)
    }.merge(params[:data] || {})
  end

  def api_button_subject(params)
    subject = params.fetch(:subject) || []
    if subject.is_a?(Array)
      subject
    else
      [subject]
    end
  end
end
