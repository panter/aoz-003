module FilterDropdownHelper
  def list_eq_filter_dropdown(attribute, collection, t_scope = nil)
    t_scope ||= [:simple_form, :options, controller_name.singularize.to_sym]
    t_scope = { scope: t_scope.push(attribute) }
    filter_links = collection.map do |item|
      list_filter_link("#{attribute}_eq".to_sym, item, t_scope)
    end
    dropdown_list_element(attribute, filter_links, t_scope, "#{attribute}_eq".to_sym)
  end

  def list_boolean_filter_dropdown(attribute_group, collection, t_scope = nil)
    q_filters = collection.map { |attribute| "#{attribute}_true".to_sym }
    t_scope = { scope: t_scope || [:activerecord, :attributes, controller_name.singularize.to_sym] }
    filter_links = q_filters.each_with_index.map do |q_filter, index|
      list_filter_link(q_filter, collection[index], t_scope, bool_filter: true)
    end
    dropdown_list_element(attribute_group, filter_links, t_scope, *q_filters)
  end

  def dropdown_list_element(attribute, filter_links, t_scope, *q_filters)
    content_tag :li, class: 'dropdown' do
      concat dropdown_toggle_link(attribute, t_scope, q_filters)
      concat dropdown_menu(filter_links, q_filters)
    end
  end

  def list_filter_link(q_filter, filter_attribute, t_scope, bool_filter: false)
    link_class = 'bg-success' if filter_active?(q_filter, filter_attribute)
    content_tag :li do
      link_to(filter_url(q_filter, bool_filter, filter_attribute), class: link_class) do
        translate_value(filter_attribute, t_scope)
      end
    end
  end

  def filter_url(q_filter, bool_filter, filter_attribute)
    if filter_active?(q_filter, filter_attribute)
      url_for(q: search_parameters.except(q_filter))
    else
      filter_parameter = { q_filter => bool_filter || filter_attribute }
      url_for(q: search_parameters.merge(filter_parameter))
    end
  end

  def filter_active?(q_filter, filter_attribute)
    [filter_attribute.to_s, 'true'].include? search_parameters[q_filter]
  end

  def dropdown_menu(filter_links, q_filters)
    content_tag :ul, class: 'dropdown-menu' do
      concat content_tag(:li, link_to(t('all'), url_for(q: search_parameters.except(*q_filters))))
      concat content_tag :li, '', class: 'divider', role: 'separator'
      filter_links.each { |item| concat item }
    end
  end

  def dropdown_toggle_link(attribute, t_scope, q_filter)
    content_tag :a, dropdown_toggler_options do
      concat toggler_text(attribute, q_filter, t_scope)
      concat content_tag(:span, '', class: 'caret')
    end
  end

  def toggler_text(attribute, q_filter, t_scope)
    return "#{t_attr(attribute)} " if q_filter.size > 1
    "#{t_attr(attribute)}: #{translate_value(search_parameters[q_filter[0]], t_scope)} "
  end

  def dropdown_toggler_options
    { class: 'dropdown-toggle btn btn-default btn-sm', srole: 'button', href: '#',
      aria: { expanded: 'false', haspopup: 'true', toggle: 'dropdown' },
      data: { toggle: 'dropdown' } }
  end

  def translate_value(filter_attribute, t_scope)
    return t('all') if filter_attribute.blank?
    t(filter_attribute, t_scope)
  end

  def search_parameters
    @search_parameters ||= params[:q]&.to_unsafe_hash || {}
  end
end
