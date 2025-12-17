class MarkdownRenderer
  def initialize(content)
    @content = content.to_s
  end

  def to_html
    return '' if @content.blank?

    # Start with the raw content
    html_content = @content.dup

    # Apply markdown transformations in order
    html_content = convert_code_blocks(html_content)
    html_content = convert_headers(html_content)
    html_content = convert_bold_italic(html_content)
    html_content = convert_links(html_content)
    html_content = convert_lists(html_content)
    html_content = convert_inline_code(html_content)
    html_content = convert_line_breaks(html_content)

    # Use ActionText for final sanitization and safety
    ActionText::Content.new(html_content).to_s.html_safe
  rescue StandardError => e
    Rails.logger.error "MarkdownRenderer error: #{e.message}"
    # Return sanitized plain text as fallback
    ActionText::Content.new(@content).to_s.html_safe
  end

  private

  def convert_code_blocks(content)
    # Convert fenced code blocks (```code```)
    content.gsub(/```(\w+)?\n(.*?)\n```/m) do |match|
      language = $1
      code = $2
      language_class = language.present? ? " class=\"language-#{language}\"" : ""
      "<pre><code#{language_class}>#{CGI.escapeHTML(code)}</code></pre>"
    end
  end

  def convert_headers(content)
    content.gsub(/^(#+)\s+(.+)$/) do |match|
      hashes = $1
      text = $2.strip
      level = hashes.length
      "<h#{level}>#{text}</h#{level}>"
    end
  end

  def convert_bold_italic(content)
    # Convert bold (**text** or __text__)
    content = content.gsub(/\*\*(.*?)\*\*/, '<strong>\1</strong>')
    content = content.gsub(/__(.*?)__/, '<strong>\1</strong>')
    
    # Convert italic (*text* or _text_)
    content = content.gsub(/\*([^*]+)\*/, '<em>\1</em>')
    content = content.gsub(/_([^_]+)_/, '<em>\1</em>')
    
    content
  end

  def convert_links(content)
    # Convert markdown links [text](url)
    content.gsub(/\[([^\]]+)\]\(([^)]+)\)/) do |match|
      text = $1
      url = $2
      "<a href=\"#{CGI.escapeHTML(url)}\">#{text}</a>"
    end
  end

  def convert_lists(content)
    lines = content.split("\n")
    result = []
    in_ul = false
    in_ol = false

    lines.each do |line|
      # Unordered list items
      if line.match(/^\s*[-*+]\s+(.+)/)
        unless in_ul
          result << '<ul>'
          in_ul = true
        end
        if in_ol
          result << '</ol>'
          in_ol = false
        end
        result << "<li>#{$1}</li>"
      # Ordered list items
      elsif line.match(/^\s*\d+\.\s+(.+)/)
        unless in_ol
          result << '<ol>'
          in_ol = true
        end
        if in_ul
          result << '</ul>'
          in_ul = false
        end
        result << "<li>#{$1}</li>"
      else
        # Close any open lists
        if in_ul
          result << '</ul>'
          in_ul = false
        end
        if in_ol
          result << '</ol>'
          in_ol = false
        end
        result << line
      end
    end

    # Close any remaining open lists
    result << '</ul>' if in_ul
    result << '</ol>' if in_ol

    result.join("\n")
  end

  def convert_inline_code(content)
    # Convert inline code `code`
    content.gsub(/`([^`]+)`/, '<code>\1</code>')
  end

  def convert_line_breaks(content)
    # Convert double line breaks to paragraphs
    paragraphs = content.split(/\n\s*\n/)
    paragraphs.map do |paragraph|
      paragraph.strip.empty? ? '' : "<p>#{paragraph.gsub(/\n/, '<br>')}</p>"
    end.reject(&:empty?).join("\n")
  end
end