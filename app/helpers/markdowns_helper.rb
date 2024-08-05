module MarkdownsHelper
  def markdown content
    Markdown.new(content).to_html.html_safe # rubocop:disable Rails/OutputSafety
  end
end
