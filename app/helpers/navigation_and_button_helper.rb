module NavigationAndButtonHelper
  def form_navigation_btn(action, cols: 12, with_row: true, md_cols: nil, with_col: false,
    add_class: nil)
    button = make_nav_button(action)
    button = bootstrap_col(cols, md_cols) { button } if with_col || with_row
    button = boostrap_row(add_class) { button } if with_row
    button
  end

  def button_link(text, target, type = 'default', dimension: nil, **options)
    btn_size = " btn-#{dimension}" if dimension
    link_to text, target, class: "btn btn-#{type}#{btn_size}", **options
  end

  def make_nav_button(action)
    if action == :back
      text = navigation_glyph(:back)
      action = :index
    else
      text = t_title(action)
    end
    button_link(text,
      controller: controller_name, action: action, id: action == :index ? nil : params[:id])
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
      show: { text: 'Anzeigen', glyph: 'eye-open' },
      edit: { text: 'Bearbeiten', glyph: 'pencil' },
      delete: { text: 'Löschen', glyph: 'trash' },
      terminate: { text: 'Beenden', glyph: 'off' },
      activate: { text: 'Aktivieren', glyph: 'ok' },
      deactivate: { text: 'Deaktivieren', glyph: 'remove' },
      back: { text: 'Zurück', glyph: 'arrow-left' },
      print: { text: 'Ausdrucken', glyph: 'print' },
      download: { text: 'Herunterladen', glyph: 'download-alt' },
      yes: { text: 'Ja', glyph: 'ok' },
      no: { text: 'Nein', glyph: 'remove' }
    }
    glyph_span(translate_glyph[icon_type.to_sym])
  end

  def glyph_span(text: 'Zurück', glyph: 'arrow-left')
    tag.span(class: "glyphicon glyphicon-#{glyph}") do
      tag.span(text, class: 'sr-only')
    end
  end

  def navigation_fa_icon(icon_type = :xlsx)
    translate_fa = {
      xlsx: { text: 'Excel herunterladen', fa_type: 'file-excel-o' }
    }
    fa_span(translate_fa[icon_type.to_sym])
  end

  def fa_span(text: 'xlsx', fa_type: 'file-excel-o')
    tag.span(class: "fa fa-#{fa_type}") do
      tag.span(text, class: 'sr-only')
    end
  end

  def assignment_status_badge(assignment, css = 'btn-xs')
    if assignment.active?
      link_to 'Aktiv', '#', class: "btn btn-acceptance-undecided #{css}"
    else
      link_to 'Inaktiv', '#', class: "btn btn-acceptance-resigned #{css}"
    end
  end
end
