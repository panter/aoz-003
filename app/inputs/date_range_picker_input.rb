class DateRangePickerInput < SimpleForm::Inputs::Base
  def input
    template.content_tag(:fieldset) do
      template.concat content_tag(:legend,
        I18n.t("activerecord.attributes.#{object_name}.#{attribute_name}"))
      template.concat range_fields(template)
      template.concat year_buttons(template)
    end
  end

  def year_buttons(template)
    template.content_tag(:ul, id: "#{object_name}_#{attribute_name}_years",
      class: 'list-inline year-togglers') do
      (0..9).to_a.reverse.each do |index|
        template.concat year_link(template, Time.zone.now.to_date.year - index)
      end
    end
  end

  def year_link(template, year)
    template.content_tag(:li) do
      template.content_tag(:div, year.to_s, class: 'btn btn-default btn-sm', data: { year: year })
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
    name = { name: "#{object_name}[#{attribute}]" }
    html_opts = input_html_options.merge(name)
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
