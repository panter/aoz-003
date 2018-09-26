module NavigationAndButtonHelper
  GLYPH_TRANSLATE = {
    show: { text: 'Anzeigen', icon_type: 'eye-open' },
    edit: { text: 'Bearbeiten', icon_type: 'pencil' },
    delete: { text: 'Löschen', icon_type: 'trash' },
    terminate: { text: 'Beenden', icon_type: 'off' },
    activate: { text: 'Aktivieren', icon_type: 'ok' },
    deactivate: { text: 'Deaktivieren', icon_type: 'remove' },
    back: { text: 'Zurück', icon_type: 'arrow-left' },
    print: { text: 'Ausdrucken', icon_type: 'print' },
    download: { text: 'Herunterladen', icon_type: 'download-alt' },
    yes: { text: 'Ja', icon_type: 'ok' },
    no: { text: 'Nein', icon_type: 'remove' },
    journal: { text: 'Journal', icon_type: 'book' },
    journal_new: { text: 'Neuen Journal eintrag erstellen', type: :fa, icon_type: :edit },
    hours: { text: 'Stunden erfassen', icon_type: 'time' },
    billing_expenses: { text: 'Spesen', icon_type: 'usd' },
    assignment: { text: 'Begleitung', icon_type: 'user' },
    certificate: { text: 'Nachweis', icon_type: 'education' },
    xlsx: { text: 'Excel herunterladen', type: :fa, icon_type: 'file-excel-o' },
    truthy: { text: 'true', icon_type: :ok, extra_class: 'text-success' },
    falsy: { text: 'false', icon_type: :remove, extra_class: 'text-danger' }
  }.freeze

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

  def yield_button_link(target, **options)
    btn_size = options[:dimension] && " btn-#{options[:dimension]}"
    type = options.delete(:type)
    link_to(target, class: "btn btn-#{type || 'default'}#{btn_size}", **options) do
      yield
    end
  end

  # bootstrap button link with action glyphicon
  # Params:
  #   action_type           - one of GLYPH_TRANSLATE's keys
  #   target                - the path target for the link
  #   title: 'string'       - optional title attribute, else it will be taken from
  #                             GLYPH_TRANSLATE[action_type][:text]
  #   dimension: [xs|md|lg] - optional dimension (Bootstrap's: xs, lg, md)
  #   ..options             - any optional parameter link_to accepts
  def glyph_action_button_link(action_type, target, **options)
    options[:title] ||= GLYPH_TRANSLATE[action_type.to_sym][:text]
    yield_button_link(target, **options) do
      icon_span(action_type)
    end
  end

  def make_nav_button(action)
    if action == :back
      text = icon_span(:back)
      action = :index
    else
      text = t_title(action)
    end
    button_link(text,
      controller: controller_name, action: action, id: action == :index ? nil : params[:id])
  end

  def boolean_glyph(value)
    if value
      icon_span(:truthy)
    else
      icon_span(:falsy)
    end
  end

  def icon_span(icon = :back)
    glyph = GLYPH_TRANSLATE[icon]
    style = icon_class(glyph&.fetch(:icon_type, 'arrow-left'), glyph&.fetch(:type, :glyphicon),
      glyph&.fetch(:extra_class, nil))
    tag.span(class: style) do
      tag.span(glyph&.fetch(:text, 'Zurück'), class: 'sr-only')
    end
  end

  def icon_class(icon_type = 'arrow-left', type = :glyphicon, extra_class = nil)
    "#{type} #{type}-#{icon_type}#{extra_class && " #{extra_class}"}"
  end

  def assignment_status_badge(assignment, css = 'btn-xs')
    if assignment.active?
      link_to 'Aktiv', '#', class: "btn btn-acceptance-undecided #{css}"
    else
      link_to 'Inaktiv', '#', class: "btn btn-acceptance-resigned #{css}"
    end
  end
end
