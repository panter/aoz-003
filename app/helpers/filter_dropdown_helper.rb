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
        concat li_a_element(on_text, bool_toggle_url(filter, true),
          class: list_filter_link_class(filter, 'true'))
        concat li_a_element(off_text, bool_toggle_url(filter, false),
          class: list_filter_link_class(filter, 'false'))
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
    filter_keys += filters.map { |filter| filter[:qs] }
    li_dropdown do
      concat dropdown_toggle_link(name + custom_text_end(filters))
      concat dropdown_ul(tag.li { all_link_to(filter_keys) }) {
        filters.map do |filter|
          concat li_a_element(filter[:text], custom_filter_url(
              filter[:q],
              filter[:qs],
              filter[:value],
              *filter_keys.reject { |key| key == filter[:q] }.reject { |key| filter[:qs]&.include? key }
          ),
            class: list_filter_link_class(filter[:q], filter[:value]))
        end
      }
    end
  end

  def custom_text_end(filters)
    in_search = custom_text_filter_in_search(filters)
    if in_search.blank?
      ''
    elsif in_search.size == 1
      ": #{in_search.first[:text]}"
    else
      ": #{custom_text_filter_value_in_search(in_search)[:text]}"
    end
  end

  def custom_text_filter_in_search(filters)
    filters.find_all do |filter|
      search_parameters.keys.include? filter[:q].to_s
    end
  end

  def custom_text_filter_value_in_search(in_search)
    in_search.find do |filter|
      filter[:value].to_s == search_parameters[filter[:q]].to_s
    end
  end

  def custom_filter_url(filter, multi_qs, value, *excludes)
    q_values = search_parameters.except(*excludes).merge("#{filter}": value.to_s)
    q_values = q_values.merge(multi_qs.map { |q| [q, value.to_s] }.to_h) if multi_qs
    url_for(params_except('page').merge(q: q_values))
  end

  def bool_toggle_url(filter, toggle = false)
    url_for(params_except('page').merge(q: search_parameters.merge("#{filter}": toggle.to_s)))
  end

  def bool_toggler_text_end(filter, on_text, off_text)
    case search_parameters[filter]
    when 'true'
      ": #{on_text} "
    when 'false'
      ": #{off_text} "
    else
      ' '
    end
  end

  def params_except(*key)
    params.to_unsafe_hash.except(*key)
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

  def list_filter_link(q_filter, filter_attribute, bool_filter: false)
    tag.li do
      link_to(
        filter_url(q_filter, bool_filter, filter_attribute),
        class: list_filter_link_class(q_filter, filter_attribute)
      ) do
        translate_value(filter_attribute, q_filter)
      end
    end
  end

  def list_filter_link_class(filter, value)
    if !filter_active?(filter, value)
      ''
    elsif filter == :acceptance_scope
      "bg-#{value}"
    else
      'bg-success'
    end
  end

  def li_a_element(text, href, *options)
    tag.li do
      link_to(text, href, *options)
    end
  end

  def filter_url(q_filter, bool_filter, filter_attribute)
    if filter_active?(q_filter, filter_attribute)
      url_for(params_except('page').merge(q: search_parameters.except(q_filter)))
    else
      filter_parameter = { q_filter => bool_filter || filter_attribute }
      url_for(params_except('page').merge(q: search_parameters.merge(filter_parameter)))
    end
  end

  def filter_active?(filter, value)
    [value.to_s, 'true'].include? search_parameters[filter]
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
    '%{att}: %{val}' % {
      att: t_attr(attribute),
      val: translate_value(search_parameters[q_filter[0]], q_filter)
    }
  end

  def dropdown_toggler_options
    { class: 'dropdown-toggle btn btn-default btn-sm', role: 'button', href: '#',
      data: { toggle: 'dropdown' }, aria: { expanded: 'false', haspopup: 'true' } }
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
