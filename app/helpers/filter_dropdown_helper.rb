module FilterDropdownHelper
  def list_eq_filter_dropdown(attribute, collection, t_scope: nil)
    set_local_q
    t_scope ||= [:simple_form, :options, controller_name.singularize.to_sym]
    @t_scope = { scope: t_scope.push(attribute) }
    filter_links = collection.map { |item| list_filter_link("#{attribute}_eq".to_sym, item) }
    container_li attribute, filter_links, "#{attribute}_eq".to_sym
  end

  def list_boolean_filter_dropdown(attribute_group, collection, t_scope: nil)
    set_local_q
    @t_scope = {
      scope: t_scope || [:activerecord, :attributes, controller_name.singularize.to_sym]
    }
    q_filters = collection.map { |attribute| "#{attribute}_eq".to_sym }
    filter_links = q_filters.each_with_index.map do |q_filter, index|
      list_filter_link q_filter, collection[index].to_sym, boolean_filter_active(@local_q[q_filter])
    end
    container_li attribute_group, filter_links, *q_filters
  end

  def container_li(attribute, filter_links, *q_filters)
    content_tag :li, class: 'dropdown' do
      concat dropdown_link(attribute, q_filters)
      concat dropdown_menu(filter_links, q_filters)
    end
  end

  def list_filter_link(q_filter, filter_value, boolean_value = nil)
    link_class = 'bg-success' if [filter_value.to_s, 'true'].include? @local_q[q_filter]
    link_text = translate_value(filter_value)
    filter_value = true if !boolean_value.nil? && boolean_value
    filter_value = '' if !boolean_value.nil? && !boolean_value
    content_tag :li do
      link_to link_text, filter_link(q_filter, filter_value), class: link_class
    end
  end

  def dropdown_menu(filter_links, q_filters)
    content_tag :ul, class: 'dropdown-menu' do
      concat deactivate_link(q_filters)
      concat content_tag :li, '', class: 'divider', role: 'separator'
      filter_links.collect { |item| concat item }
    end
  end

  def dropdown_link(attribute, q_filter = nil)
    options = { class: 'dropdown-toggle btn btn-default btn-sm',
                aria: { expanded: 'false', haspopup: 'true', toggle: 'dropdown' },
                role: 'button', href: '#', data: { toggle: 'dropdown' } }
    content_tag :a, options do
      concat t_attr(attribute)
      concat ': ' if q_filter.size == 1
      concat translate_value(@local_q[q_filter[0]]) if q_filter.size == 1
      concat ' '
      concat content_tag(:span, '', class: 'caret')
    end
  end

  def deactivate_link(q_filters)
    link_href = "#{request.path}?" + {
      q: @local_q.except(*q_filters)
    }.to_query
    content_tag :li do
      link_to t('all'), link_href
    end
  end

  def boolean_filter_active(actual_filter)
    return 'false' if ['false', '', nil].include? actual_filter
    true if actual_filter == 'true'
  end

  def translate_value(filter_value)
    return t('all') if ['all', '', nil].include? filter_value
    t(filter_value, @t_scope)
  end

  def filter_link(q_filter, filter_value)
    filter_value = '' if filter_value == 'all'
    "#{request.path}?" + {
      q: @local_q.except(q_filter).merge(q_filter => filter_value)
    }.to_query
  end

  def set_local_q
    @local_q = request.GET[:q] || {}
  end
end
