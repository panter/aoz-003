module FilterDropdownHelper
  def custom_filter_dropdown(name, *filters)
    _custom_filter_dropdown_general(name, true, *filters)
  end

  def custom_filter_dropdown_no_all(name, *filters)
    _custom_filter_dropdown_general(name, false, *filters)
  end

  def _custom_filter_dropdown_general(name, all_link, *filters)
    filter_keys = filters.map { |filter| filter[:q] }
    filter_keys += filters.map { |filter| filter[:qs] }
    filters = custom_filter_dropdown_filters(filters, filter_keys)

    render_filter_dropdown top_text: name + custom_text_end(filters),
      all_url: filter_keys, filters: filters, all_link: all_link
  end

  def custom_filter_dropdown_filters(filters, filter_keys)
    filters.map do |filter|
      filter[:active] = filter_active?(filter[:q], filter[:value])
      excludes = filter_keys.reject { |key| key == filter[:q] }
      excludes = excludes.reject { |key| filter[:qs]&.include? key } if filter[:qs]&.any?
      q_args = params_except('page').merge(
        q: custom_filter_q_arg(*filter.values_at(:q, :qs, :value), *excludes)
      )
      filter.merge(url: url_for(q_args), link_class: list_filter_link_class(filter[:active]))
    end
  end

  def custom_filter_q_arg(filter, multi_qs, value, *excludes)
    q_values = search_parameters.merge(multi_qs.map { |q| [q, value.to_s] }.to_h) if multi_qs
    (q_values || search_parameters).except(*excludes).merge("#{filter}": value.to_s)
  end

  def list_filter_dropdown(attribute, collection = nil)
    attribute_q = "#{attribute}_eq".to_sym
    filters = collection.map do |item|
      filter = { q: attribute_q, value: item, active: filter_active?(attribute_q, item) }
      filter.merge(
        text: translate_value(*filter.values_at(:value, :q)),
        url: filter_dropdown_url(*filter.values_at(:q, :value)),
        link_class: list_filter_link_class(*filter.values_at(:active, :value, :q))
      )
    end
    render_filter_dropdown top_text: toggler_text(attribute.to_sym, [attribute_q]),
      all_url: attribute_q, filters: filters, all_link: true
  end

  def boolean_filter_dropdown(attribute, collection = nil)
    filters = collection.map do |filter|
      q = "#{filter}_true".to_sym
      filter = { q: q, active: filter_active?(q, true) }
      filter.merge(
        text: translate_value(filter, q),
        url: filter_dropdown_url(q, search_parameters[filter], true),
        link_class: list_filter_link_class(filter[:active])
      )
    end
    render_filter_dropdown top_text: toggler_text(attribute, filters.pluck(:q)),
      all_url: filters.pluck(:q), filters: filters, all_link: true
  end

  # Creates a filter dropdown that filters a boolean attribute to either true or false
  # Params:
  # attribute - the model attribute name as string or symbol
  # attr_text - the text displayed for the dropdown title
  # on_text   - text for filtering true
  # off_text  - text for filtering false
  def boolean_toggler_filter_dropdown(attribute, attr_text, on_text, off_text)
    filters = { q: "#{attribute}_eq" }
    true_active = filter_active?(filters[:q], 'true')
    false_active = true_active ? false : filter_active?(filters[:q], 'false')
    render_filter_dropdown(all_url: filters[:q], filters: [
      filters.merge(text: on_text, url: bool_toggle_url(filters[:q], true),
        link_class: list_filter_link_class(true_active)),
      filters.merge(text: off_text, url: bool_toggle_url(filters[:q], false),
        link_class: list_filter_link_class(false_active))
    ], top_text: attr_text + bool_toggler_text_end(filters[:q], on_text, off_text))
  end

  def render_filter_dropdown(locals)
    locals.merge!(all_url: all_url_for(locals[:all_url])) if locals[:all_link]
    render template: 'application/filter_dropdown', locals: locals
  end

  def custom_text_end(filters)
    in_search = filters.find_all { |filter| search_parameters.key?(filter[:q].to_s) }
    if in_search.blank?
      ' '
    else
      ': %s' % [in_search.find { |h| h[:active] }[:text]]
    end
  end

  def all_url_for(q_filters)
    filter = search_parameters.except(*q_filters)
    filter = { all: true } if filter.empty?
    if @global_filters
      return url_for({q: filter}.merge @global_filters)
    end
    url_for(q: filter)
  end

  def filter_dropdown_url(q_filter, filter_attribute, bool = false)
    q_params =
      if filter_active?(q_filter, bool || filter_attribute)
        search_parameters.except(q_filter)
      else
        search_parameters.merge(q_filter => bool || filter_attribute)
      end
    url_for(params_except('page').merge(q: q_params))
  end

  def list_filter_link_class(active, value = nil, filter = nil)
    return '' unless active
    if [:process_eq, :acceptance_eq].include? filter
      "bg-#{value}"
    else
      'bg-success'
    end
  end

  def bool_toggle_url(filter, toggle = false)
    url_for(params_except('page').merge(q: search_parameters.merge("#{filter}": toggle.to_s)))
  end

  def toggler_text(attribute, q_filter)
    if q_filter.size > 1 || search_parameters[q_filter[0]].nil?
      t_attr(attribute)
    else
      "#{t_attr(attribute)}: #{translate_value(search_parameters[q_filter[0]], q_filter)}"
    end
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

  def clear_filter_button
    filter = { all: true, s: params.dig(:q, :s) }.compact
    button_link t('clear_filters'), url_for(q: filter), dimension: :sm
  end

  def params_except(*key)
    params.to_unsafe_hash.except(*key)
  end

  def filter_active?(filter, value)
    value.present? && search_parameters[filter].to_s == value.to_s
  end

  def translate_value(filter_attribute, q_filter)
    return t('all') if filter_attribute.blank?
    q_filter = q_filter.is_a?(Symbol) ? q_filter.to_s : q_filter.first.to_s
    if q_filter.slice! '_true'
      t_attr(q_filter)
    elsif q_filter.slice! '_eq'
      t("simple_form.options.#{controller_name.singularize}.#{q_filter}.#{filter_attribute}")
    end
  end
end
