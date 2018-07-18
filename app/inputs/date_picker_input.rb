class DatePickerInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    attribute_value = @builder.object.send(attribute_name.to_sym)
    html_opts = input_html_options
    html_opts = html_opts.merge(
      value: localize(attribute_value)
    ) unless attribute_value.nil?
    @builder.text_field(attribute_name, html_opts)
  end

  def input_html_options
    super.merge(class: 'input-sm form-control bs-datepicker-input', data: { provide: 'datepicker' })
  end
end
