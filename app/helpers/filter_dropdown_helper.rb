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

  # Creates a filter dropdown for an enum attribute
  # Params:
  # attribute  - the model attribute name as string or symbol
  # collection - what the rails model returns on enum all (eg. enum attribute :kind -> Model.kinds)
  def enum_filter_dropdown(attribute, collection)
    filter_links = collection.map do |option|
      list_filter_link("#{attribute}_eq".to_sym, option[0], enum_value: option[1])
    end
    li_dropdown do
      concat dropdown_toggle_link(toggler_text(attribute, collection))
      concat dropdown_menu(filter_links, "#{attribute}_eq".to_sym)
    end
  end

  # Creates a filter dropdown that filters a boolean attribute to either true or false
  # Params:
  # attribute - the model attribute name as string or symbol
  # attr_text - the text displayed for the dropdown title
  # on_text   - text for filtering true
  # off_text  - text for filtering false
  def boolean_toggler_filter_dropdown(attribute, attr_text, on_text, off_text)
    filter = "#{attribute}_eq"
    li_dropdown do
      concat dropdown_toggle_link(attr_text + bool_toggler_text_end(filter, on_text, off_text))
      concat dropdown_ul(tag.li { all_link_to(filter) }) {
        concat li_a_element(on_text, bool_toggle_url(filter, true), class: q_active_class(filter, 'true'))
        concat li_a_element(off_text, bool_toggle_url(filter, false), class: q_active_class(filter, 'false'))
      }
    end
  end

  # Creates a dropdown with multiple fully customizable filters
  # Params:
  # name    - the displayed filter group name
  # filters - rest parameters of n hashes
  #           :q     - symbol defining the Ransack filter (eg. attribute_eq)
  #           :value - string passed to the Ransack filter in this link (eg. true)
  #           :text  - string for frontend display
  def custom_filter_dropdown(name, *filters)
    filter_keys = filters.map { |filter| filter[:q] }
    li_dropdown do
      concat dropdown_toggle_link(name + custom_text_end(filters))
      concat dropdown_ul(tag.li { all_link_to(filter_keys) }) {
        filters.map do |filter|
          concat li_a_element(filter[:text],
            custom_filter_url(filter[:q], filter[:value], *filter_keys.reject { |key| key == filter[:q] }),
            class: q_active_class(filter[:q], filter[:value]))
        end
      }
    end
  end

  def custom_text_end(filters)
    search_keys = search_parameters.keys
    in_search = filters.find do |filter|
      search_keys.include? filter[:q].to_s
    end
    return ": #{in_search[:text]}" if in_search.present?
    ' '
  end

  def q_active_class(filter, value)
    if q_is?(filter, value)
      'bg-success'
    else
      ''
    end
  end

  def q_true?(filter)
    search_parameters[filter] == 'true'
  end

  def q_false?(filter)
    search_parameters[filter] == 'false'
  end

  def q_is?(filter, value)
    search_parameters[filter] == value
  end

  def custom_filter_url(filter, value, *excludes)
    url_for(params_except('page').merge(q: search_parameters.except(*excludes).merge("#{filter}": value.to_s)))
  end

  def bool_toggle_url(filter, toggle = false)
    url_for(params_except('page').merge(q: search_parameters.merge("#{filter}": toggle.to_s)))
  end

  def bool_toggler_text_end(filter, on_text, off_text)
    return ": #{on_text} " if q_true?(filter)
    return ": #{off_text} " if q_false?(filter)
    ' '
  end


  def params_except(*key)
    params.to_unsafe_hash.except(*key)
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
    link_class = if q_filter == :acceptance_eq && filter_active?(q_filter, filter_attribute, enum_value)
                   "bg-#{filter_attribute}"
                 elsif filter_active?(q_filter, filter_attribute, enum_value)
                   'bg-success'
                 end
    tag.li do
      link_to(
        filter_url(q_filter, bool_filter, filter_attribute, enum_value: enum_value),
        class: link_class
      ) do
        translate_value(filter_attribute, q_filter)
      end
    end
  end

  def li_a_element(text, href, *options)
    tag.li do
      link_to(text, href, *options)
    end
  end

  def filter_url(q_filter, bool_filter, filter_attribute, enum_value: false)
    if filter_active?(q_filter, filter_attribute, enum_value)
      url_for(params_except('page').merge(q: search_parameters.except(q_filter)))
    else
      filter_parameter = { q_filter => bool_filter || enum_value || filter_attribute }
      url_for(params_except('page').merge(q: search_parameters.merge(filter_parameter)))
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
    { class: 'dropdown-toggle btn btn-default btn-sm', role: 'button', href: '#', data: { toggle: 'dropdown' },
      aria: { expanded: 'false', haspopup: 'true' } }
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
