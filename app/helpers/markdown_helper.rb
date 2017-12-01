class MdPlainText < Redcarpet::Render::StripDown
  def link(link, *_)
    link
  end
end

module MarkdownHelper
  def markdown(content)
    return '' if content.blank?
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::XHTML, autolink: false,
      disable_indented_code_blocks: true, filter_html: true,
      no_images: true, no_links: true, no_styles: true, hard_wrap: true, lax_spacing: true)
    sanitize(markdown.render(content))
  end

  # return markdown as plain text for mailers
  def markdown_plain_text(content)
    return '' if content.blank?
    markdown = Redcarpet::Markdown.new(MdPlainText, autolink: false,
      disable_indented_code_blocks: true, filter_html: true,
      no_images: true, no_links: true, no_styles: true, hard_wrap: true, lax_spacing: true)
    markdown.render(content)
  end
end
