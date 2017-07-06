module ApplicationHelper
  def permit_collection
    [:N, :F, :'B-FL', :B, :C]
  end

  def week(with_weekend = false)
    if with_weekend
      [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
    else
      [:monday, :tuesday, :wednesday, :thursday, :friday]
    end
  end

  def simple_error_notice(f)
    single_col_xs f.error_notification if f.error_notification.present?
  end

  def button_link(text, target, type = 'default')
    link_to text, target, class: "btn btn-#{type}"
  end

  def link_to_add_polymorphic_association(*args)
    name, f, association, html_options = *args
    html_options[:partial] = "#{association}/fields"
    link_to_add_association(name, f, association, html_options)
  end

  def form_navigation_btn(action, cols: 12, with_row: nil, md_cols: nil)
    text = action == :back ? t('back') : t_title(action)
    action = :index if action == :back
    target = { controller: controller_name, action: action }
    button_type = action == :new ? 'success' : 'default'
    target[:id] = params[:id] unless action == :index
    if with_row
      button_link text, target, button_type
    else
      single_col_xs button_link(text, target, button_type), cols: cols, md_cols: md_cols
    end
  end

  def single_col_xs(inside, cols: 12, md_cols: nil)
    col_class = "col-xs-#{cols}"
    col_class += " col-md-#{md_cols}" if md_cols
    content_tag :div, class: 'row' do
      content_tag :div, class: col_class do
        inside
      end
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
end
