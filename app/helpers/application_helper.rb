module ApplicationHelper
  def availability_collection
    [:flexible, :morning, :afternoon, :evening, :workday, :weekend]
  end

  def simple_error_notice(f)
    boostrap_row(f.error_notification) if f.error_notification.present?
  end

  def button_link(text, target, type = 'default')
    link_to text, target, class: "btn btn-#{type}"
  end

  def link_to_add_polymorphic_association(*args)
    name, f, association, html_options = *args
    html_options[:partial] = "#{association}/fields"
    link_to_add_association(name, f, association, html_options)
  end

  def form_navigation_btn(action, cols: 12, with_row: true, md_cols: nil, with_col: false)
    text, action, target, button_type = make_nav_button_attributes(action)
    target[:id] = params[:id] unless action == :index
    return bootstrap_row_col(button_link(text, target, button_type), cols, md_cols) if with_row
    return bootstrap_col(button_link(text, target, button_type), cols, md_cols) if with_col
    button_link text, target, button_type
  end

  def make_nav_button_attributes(action)
    text = action == :back ? t('back') : t_title(action)
    action = :index if action == :back
    target = { controller: controller_name, action: action }
    button_type = action == :new ? 'success' : 'default'
    [text, action, target, button_type]
  end

  def bootstrap_col(inside, cols = 12, md_cols = nil)
    col_class = "col-xs-#{cols}"
    col_class += " col-md-#{md_cols}" if md_cols
    content_tag :div, class: col_class do
      inside
    end
  end

  def bootstrap_row_col(inside, cols = 12, md_cols = nil)
    boostrap_row bootstrap_col(inside, cols, md_cols)
  end

  def boostrap_row(inside)
    content_tag :div, class: 'row' do
      inside
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
    f.input property, class: 'conditional-field', input_html: input_html(f, enabler, value),
      label_html: {
        class: 'conditional-field'
      }
  end

  def multi_conditional_field(f, property, enablers)
    f.input property, input_html: input_html(f, enablers, '', 'group'),
      class: 'conditional-group conditional-group-' +
        model_name_from_record_or_class(f.object).element,
      label_html: { class: 'conditional-group' }
  end

  def confirm_deleting(record)
    if controller_name == 'assignments'
      return { method: :delete, data: { confirm: t('delete_assignment') } }
    elsif controller_name == 'journals'
      return { method: :delete, data: { confirm: t('delete_journal') } }
    else
      { method: :delete, data: { confirm: t_confirm_delete(record) } }
    end
  end

  def nationality_name(nationality)
    return '' if nationality.blank?
    c = ISO3166::Country[nationality]
    c.translations[I18n.locale.to_s] || c.name
  end

  def request_filter(query, all)
    params[:q] && params[:q][query].present? ? params[:q][query] : all
  end

  def request_params_filter(query)
    params.permit!.to_h.deep_merge(q: query)
  end
end
