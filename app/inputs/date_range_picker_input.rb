class DateRangePickerInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    template.content_tag(:fieldset) do
      template.concat content_tag(:legend,
                                  I18n.t("activerecord.attributes.#{object_name}.#{attribute_name}"))
      template.concat range_fields(template)
    end
  end

  def range_fields(template)
    template.content_tag(:div, class: 'input-daterange input-group row') do
      template.concat date_field('start', template)
      template.concat date_field('end', template)
    end
  end

  def date_field(position, template)
    attribute = "#{attribute_name}_#{position}"
    attribute_value = @builder.object.send(attribute.to_sym)

    html_opts = input_html_options.merge(
      id: "#{object_name}_#{attribute}",
      name: "#{object_name}[#{attribute}]"
    )
    unless attribute_value.nil?
      html_opts = html_opts.merge(
        value: localize(attribute_value)
      )
    end

    template.content_tag(:div, class: 'form-group col-xs-6') do
      template.concat content_tag(:label,
                                  I18n.t("activerecord.attributes.#{object_name}.#{attribute}"), for: html_opts[:id])
      template.concat @builder.text_field(attribute.to_sym, html_opts)
    end
  end

  def input_html_options
    super.merge(class: 'input-sm form-control', data: { provide: 'datepicker' })
  end
end
