class DateRangePickerInput < SimpleForm::Inputs::Base
  def input
    template.content_tag(:div, class: 'input-daterange input-group') do
      template.concat date_field('start')
      template.concat content_tag(:span, 'to', class: 'input-group-addon')
      template.concat date_field('end')
    end
  end

  def date_field(position)
    @builder.text_field("#{attribute_name}_#{position}".to_sym, input_html_options(position))
  end

  def input_html_options(position = nil)
    super.merge(class: 'input-sm form-control', data: { provide: 'datepicker' },
      name: "#{object_name}[#{attribute_name}_#{position}]")
  end
end
