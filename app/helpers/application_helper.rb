module ApplicationHelper
  def availability_collection
    [:flexible, :morning, :afternoon, :evening, :workday, :weekend]
  end

  def simple_error_notice(f)
    error_message = "Es sind Fehler aufgetreten. Bitte überprüfen Sie die rot markierten Felder."
    boostrap_row { f.error_notification message: error_message } if f.error_notification.present?
  end

  def link_to_add_polymorphic_association(*args)
    name, f, association, html_options = *args
    html_options[:partial] = "#{association}/fields"
    link_to_add_association(name, f, association, html_options)
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

  def boostrap_row(add_class = nil)
    row_class = 'row'
    row_class += " #{add_class}" if add_class.present?
    content_tag :div, class: row_class do
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
    country = ISO3166::Country[nationality]
    return '' unless country
    country.translations[I18n.locale.to_s] || country.name
  end

  def request_params_filter(query)
    search_parameters.deep_merge(q: query)
  end

  def search_parameters
    @search_parameters ||= (params[:q]&.to_unsafe_hash || {}).except(:all)
  end

  def bootstrap_paginate(paginate_collection)
    will_paginate paginate_collection, renderer: WillPaginate::ActionView::Bootstrap4LinkRenderer,
      class: 'pagination-lg text-center hidden-print', 'aria-label': 'Pagination'
  end

  def profile_link(user)
    if user.volunteer?
      edit_volunteer_path(user.volunteer)
    elsif user.profile
      edit_profile_path(user.profile)
    else
      edit_user_path(user)
    end
  end

  def truncate_modal_data(body, title)
    { toggle: 'modal', target: '#truncate-modal', 'fulltext': body, title: title }
  end

  def td_truncate_content_modal(body, title, shorten_size: 40)
    return tag.td(body) if body.to_s.size < shorten_size
    tag.td(class: 'truncate-td', data: truncate_modal_data(body, title), role: 'button') do
      concat tag.span body.truncate(shorten_size)
      concat tag.span('Ganzer Text', class: 'whole-text')
    end
  end

  def section_nav_button(text, url)
    style = current_page?(url) ? 'btn-section-active' : 'btn-default'
    link_to text, url, class: "btn btn-sm #{style}"
  end

  def select_all_rows
    check_box_tag 'table-row-select-all', '', false, class: 'table-row-select-all',
      title: 'Alle auswählen'
  end

  def acceptance_select(record, form)
    collection = record.class.enum_collection(:acceptance)
    if record.resigned?
      disabled = true
    else
      disabled = false
      collection -= [:resigned]
    end

    form.input(
      :acceptance,
      include_blank: false,
      collection: collection,
      disabled: disabled
    )
  end

  def abbr(abbr, full_term)
    tag.abbr(abbr.to_s, title: full_term)
  end
end
