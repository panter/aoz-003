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
      text = navigation_glyph(:back)
      action = :index if action == :back
    else
      text = t_title(action)
    end
    button_link(text,
      controller: controller_name, action: action, id: action == :index || params[:id])
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

  def confirm_deleting(record, html_class = nil)
    { method: :delete, data: {
      confirm: t('messages.confirm_record_delete',
        model: locale == :en ? t_model(record).downcase : t_model(record))
    }, class: html_class }
  end

  def checkbox_toggle_collapse(f, field, collapse_selector, check_shows: true, label_html: nil)
    f.input(field,
      input_html: { data: { collapse: collapse_selector, check_shows: check_shows },
                    class: 'checkbox-toggle-collapse' },
      label_html: label_html)
  end

  def single_field_fieldset(f, field, input_html: nil, fieldset_html: nil, legend_html: nil)
    tag.fieldset(fieldset_html) do
      concat tag.legend(legend_html) { t("simple_form.labels.#{f.object.class.name.underscore}.#{field}") }
      concat f.label(field, class: 'sr-only')
      concat f.input(field, label: false, input_html: input_html)
    end
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

  def boolean_glyph(value)
    if value
      content_tag(:i, '', class: 'glyphicon glyphicon-ok text-success')
    else
      content_tag(:i, '', class: 'glyphicon glyphicon-remove text-danger')
    end
  end

  def navigation_glyph(icon_type = :back)
    translate_glyph = {
      back: { text: 'Back', glyph: 'arrow-left' },
      print: { text: 'Print', glyph: 'print' },
      delete: { text: 'Delete', glyph: 'trash' }
    }
    glyph_span(translate_glyph[icon_type.to_sym])
  end

  def glyph_span(text: 'Back', glyph: 'arrow-left')
    tag.span(class: "glyphicon glyphicon-#{glyph}") do
      tag.span(text, class: 'sr-only')
    end
  end

  def navigation_fa_icon(icon_type = :xlsx)
    translate_fa = {
      xlsx: { text: 'Excel sheet', fa_type: 'file-excel-o' }
    }
    fa_span(translate_fa[icon_type.to_sym])
  end

  def fa_span(text: 'xlsx', fa_type: 'file-excel-o')
    tag.span(class: "fa fa-#{fa_type}") do
      tag.span(text, class: 'sr-only')
    end
  end

  def bootstrap_paginate(paginate_collection)
    will_paginate paginate_collection, renderer: WillPaginate::ActionView::Bootstrap4LinkRenderer,
      class: 'pagination-lg text-center hidden-print', 'aria-label': 'Pagination'
  end

  def profile_link(user)
    if user.profile
      profile_path(user.profile)
    elsif user.volunteer?
      volunteer_path(user.volunteer)
    else
      user_path(user)
    end
  end

  def truncate_modal_data(body, title)
    { toggle: 'modal', target: '#truncate-modal', 'fulltext': body, title: title }
  end

  def td_truncate_content_modal(body, title, shorten_size: 40)
    return tag.td(body) if body.size < shorten_size
    tag.td(class: 'index-action-cell', data: truncate_modal_data(body, title), role: 'button') do
      concat tag.span body.truncate(shorten_size)
      concat tag.span('Ganzer Text', class: 'whole-text')
    end
  end

  def default_list_response_query
    { author_volunteer: 'true', reviewer_id_null: 'true', s: 'updated_at asc' }
  end

  def section_nav_button(actions_name, text, url)
    link_to_unless(action_name == actions_name, text, url, class: 'btn btn-default btn-sm') do
      link_to(text, url, class: 'btn btn-sm btn-section-active')
    end
  end
end
