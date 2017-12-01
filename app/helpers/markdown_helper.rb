require 'redcarpet/render_strip'

module MarkdownHelper
  MD_OPTIONS = {
    autolink: false, disable_indented_code_blocks: true, filter_html: true,
    no_images: true, no_styles: true, hard_wrap: true, lax_spacing: true
  }.freeze

  def markdown(content)
    return '' if content.blank?
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::XHTML, MD_OPTIONS)
    sanitize(markdown.render(content))
  end

  # return markdown as plain text for mailers
  def markdown_plain_text(content)
    return '' if content.blank?
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::StripDown, MD_OPTIONS)
    markdown.render(content)
  end
end
