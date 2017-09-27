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
    dropdown_li_container(
      dropdown_toggle_link(toggler_text(attribute, q_filters, t_scope)),
      dropdown_menu(filter_links, q_filters)
    )
  end

  def dropdown_li_container(toggler, menu)
    content_tag :li, class: 'dropdown' do
      concat toggler
      concat menu
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
    dropdown_ul(content_tag(:li, all_link_to(q_filters))) do
      filter_links.each { |item| concat item }
    end
  end

  def all_link_to(q_filters)
    link_to t('all'), url_for(q: search_parameters.except(*q_filters))
  end

  def dropdown_ul(all_list_link)
    content_tag :ul, class: 'dropdown-menu' do
      concat all_list_link
      concat dropdown_divider
      yield
    end
  end

  def dropdown_divider
    content_tag :li, '', class: 'divider', role: 'separator'
  end

  def dropdown_toggle_link(title_text)
    content_tag :a, dropdown_toggler_options do
      concat title_text + ' '
      concat bootstrap_caret
    end
  end

  def bootstrap_caret
    content_tag :span, '', class: 'caret'
  end

  def toggler_text(attribute, q_filter, t_scope)
    return t_attr(attribute) if q_filter.size > 1
    '%s: %s' % [t_attr(attribute), translate_value(search_parameters[q_filter[0]], t_scope)]
  end

  def dropdown_toggler_options
    toggle_drop = { toggle: 'dropdown' }
    { class: 'dropdown-toggle btn btn-default btn-sm', role: 'button', href: '#', data: toggle_drop,
      aria: { expanded: 'false', haspopup: 'true' }.merge(toggle_drop) }
  end

  def translate_value(filter_attribute, t_scope)
    return t('all') if filter_attribute.blank?
    unless filter_attribute.class == Department || filter_attribute.to_s.to_i != 0
      return t(filter_attribute, t_scope)
    end
    filter_attribute.to_s
  end
end
