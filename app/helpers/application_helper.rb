module ApplicationHelper
  def availability_collection
    [:flexible, :morning, :afternoon, :evening, :workday, :weekend]
  end

  def simple_error_notice(f)
    boostrap_row { f.error_notification } if f.error_notification.present?
  end

  def button_link(text, target, type = 'default', dimension: nil)
    btn_size = " btn-#{dimension}" if dimension
    link_to text, target, class: "btn btn-#{type}#{btn_size}"
  end

  def link_to_add_polymorphic_association(*args)
    name, f, association, html_options = *args
    html_options[:partial] = "#{association}/fields"
    link_to_add_association(name, f, association, html_options)
  end

  def form_navigation_btn(action, cols: 12, with_row: true, md_cols: nil, with_col: false)
    button = make_nav_button(action)
    button = bootstrap_col(cols, md_cols) { button } if with_col || with_row
    button = boostrap_row { button } if with_row
    button
  end

  def make_nav_button(action)
    if action == :back
      text = t('back')
      action = :index if action == :back
    else
      text = t_title(action)
    end
    button_link(text,
      { controller: controller_name, action: action, id: action == :index || params[:id] },
      action == :new ? 'success' : 'default')
  end

  def bootstrap_col(cols = 12, md_cols = nil)
    col_class = "col-xs-#{cols}"
    col_class += " col-md-#{md_cols}" if md_cols
    content_tag :div, class: col_class do
      yield
    end
  end

  def bootstrap_row_col(cols = 12, md_cols = nil)
    boostrap_row do
      bootstrap_col(cols, md_cols) do
        yield
      end
    end
  end

  def boostrap_row
    content_tag :div, class: 'row' do
      yield
    end
  end

  def input_html(f, enabler, value, type = 'field')
    { class: "conditional-#{type}", data: {
      model: model_name_from_record_or_class(f.object).element,
      subject: enabler,
      value: value
    } }
  end

  def conditional_field(f, property, enabler, value = '')
    css_class = { class: 'conditional-field' }
    f.input property, css_class, input_html: input_html(f, enabler, value), label_html: css_class
  end

  def multi_conditional_field(f, property, enablers)
    f.input property, input_html: input_html(f, enablers, '', 'group'),
      class: 'conditional-group conditional-group-' +
        model_name_from_record_or_class(f.object).element,
      label_html: { class: 'conditional-group' }
  end

  def confirm_deleting(record)
    if ['assignments', 'journals'].include? controller_name
      confirm_text = t("delete_#{controller_name.singularize}")
    end
    { method: :delete, data: { confirm: confirm_text || t_confirm_delete(record) } }
  end

  def nationality_name(nationality)
    return '' if nationality.blank?
    c = ISO3166::Country[nationality]
    c.translations[I18n.locale.to_s] || c.name
  end

  def request_filter(query, all)
    params.try(:q).try(query) || all
  end

  def request_params_filter(query)
    search_parameters.deep_merge(q: query)
  end

  def search_parameters
    @search_parameters ||= params[:q]&.to_unsafe_hash || {}
  end
end
