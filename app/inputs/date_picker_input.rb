class DatePickerInput < SimpleForm::Inputs::Base
  def input
    template.content_tag(:div, class: 'input-group date form_datetime input-date-picker') do
      template.concat @builder.text_field(attribute_name, input_html_options)
    end
  end

  def input_html_options
    super.merge(class: 'input-sm form-control', data: { provide: 'datepicker' })
  end
end
