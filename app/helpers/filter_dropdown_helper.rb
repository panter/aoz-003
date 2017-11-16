module FilterDropdownHelper
  def list_filter_dropdown(attribute, collection = nil)
    filter_links = collection.map do |item|
      list_filter_link("#{attribute}_eq".to_sym, item)
    end
    dropdown_list_filter(attribute, filter_links, "#{attribute}_eq".to_sym)
  end

  def boolean_filter_dropdown(attribute_group, collection = nil)
    q_filters = collection.map { |attribute| "#{attribute}_true".to_sym }
    filter_links = q_filters.each_with_index.map do |q_filter, index|
      list_filter_link(q_filter, collection[index], bool_filter: true)
    end
    dropdown_list_filter(attribute_group, filter_links, *q_filters)
  end

  def enum_filter_dropdown(attribute, collection)
    filter_links = collection.map do |option|
      list_filter_link("#{attribute}_eq".to_sym, option[0], enum_value: option[1])
    end
    li_dropdown do
      concat dropdown_toggle_link(toggler_text(attribute, collection))
      concat dropdown_menu(filter_links, "#{attribute}_eq".to_sym)
    end
  end

  def activeness_filter_dropdown
    li_dropdown do
      concat dropdown_toggle_link('Status' + status_toggler_text_end)
      concat dropdown_ul(tag.li { all_link_to(:active_eq) }) { activeness_links }
    end
  end

  def status_toggler_text_end
    return ' ' unless search_parameters['active_eq']
    if search_parameters['active_eq'] == 'true'
      ': Aktiv '
    elsif search_parameters['active_eq'] == 'false'
      ': Inaktiv '
    end
  end

  def activeness_links
    params_u = params.to_unsafe_hash.except('page')
    [
      tag.li do
        link_to('Aktiv ', url_for(params_u.merge(q: search_parameters.merge(active_eq: 'true'))))
      end,
      tag.li do
        link_to('Inaktiv ', url_for(params_u.merge(q: search_parameters.merge(active_eq: 'false'))))
      end
    ].collect { |li| concat li }
  end

  def enum_toggler_text(attribute, collection)
    if filter_active?("#{attribute}_eq".to_sym, '', search_parameters["#{attribute}_eq"])
      "#{t_attr(attribute)}: " + collection.invert[search_parameters["#{attribute}_eq"].to_i].humanize
    else
      "#{t_attr(attribute)} "
    end
  end

  def dropdown_list_filter(attribute, filter_links, *q_filters)
    li_dropdown do
      concat dropdown_toggle_link(toggler_text(attribute, q_filters))
      concat dropdown_menu(filter_links, q_filters)
    end
  end

  def li_dropdown
    tag.li class: 'dropdown' do
      yield
    end
  end

  def list_filter_link(q_filter, filter_attribute, bool_filter: false, enum_value: false)
    link_class = 'bg-success' if filter_active?(q_filter, filter_attribute, enum_value)
    tag.li do
      link_to(
        filter_url(q_filter, bool_filter, filter_attribute, enum_value: enum_value),
        class: link_class
      ) do
        translate_value(filter_attribute, q_filter)
      end
    end
  end

  def filter_url(q_filter, bool_filter, filter_attribute, enum_value: false)
    if filter_active?(q_filter, filter_attribute, enum_value)
      url_for(q: search_parameters.except(q_filter))
    else
      filter_parameter = { q_filter => bool_filter || enum_value || filter_attribute }
      url_for(q: search_parameters.merge(filter_parameter))
    end
  end

  def filter_active?(q_filter, filter_attribute, enum_value = nil)
    [filter_attribute.to_s, 'true', enum_value.to_s].include? search_parameters[q_filter]
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
    tag.ul class: 'dropdown-menu' do
      concat all_list_link
      concat tag.li class: 'divider', role: 'separator'
      yield
    end
  end

  def dropdown_toggle_link(title_text)
    tag.a dropdown_toggler_options do
      concat title_text + ' '
      concat tag.span class: 'caret'
    end
  end

  def toggler_text(attribute, q_filter)
    return t_attr(attribute) if q_filter.size > 1 || search_parameters[q_filter[0]].nil?
    '%s: %s' % [t_attr(attribute), translate_value(search_parameters[q_filter[0]], q_filter)]
  end

  def dropdown_toggler_options
    toggle_drop = { toggle: 'dropdown' }
    { class: 'dropdown-toggle btn btn-default btn-sm', role: 'button', href: '#', data: toggle_drop,
      aria: { expanded: 'false', haspopup: 'true' }.merge(toggle_drop) }
  end

  def translate_value(filter_attribute, q_filter)
    return t('all') if filter_attribute.blank?
    if [Department, GroupOfferCategory].include?(filter_attribute.class) ||
        filter_attribute.to_s.to_i != 0
      return filter_attribute.to_s
    end
    q_filter = q_filter.is_a?(Symbol) ? q_filter.to_s : q_filter.first.to_s
    if q_filter.slice! '_true'
      t_attr(q_filter)
    elsif q_filter.slice! '_eq'
      t("simple_form.options.#{controller_name.singularize}.#{q_filter}.#{filter_attribute}")
    end
  end
end
