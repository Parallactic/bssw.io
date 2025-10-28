# frozen_string_literal: true

# utility methods for markdown import
class MarkdownUtility < ApplicationRecord
  self.abstract_class = true

  def self.caption_regexp
    '\[(.*?)\]'
  end

  def self.modified_path(image_path)
    image_path = image_path.strip
    if image_path.match?('http')
      "#{image_path}?raw=true"
    elsif image_path
      branch = Rails.env.preview? ? 'preview' : 'main'
      path = URI(image_path).path.split('/').select do |dir|
        !dir.empty? && !dir.in?(['images', '.', '..'])
      end.join('/')
      "https://raw.githubusercontent.com/betterscientificsoftware/bssw.io/#{branch}/images/#{path}?raw=true"
    end
  end

  def self.image_classes(name)
    classes = {
      'header' => 'w_1600,h_585,c_fill',
      'logo' => 'w_200,h_200,c_fit/',
      'inline' => 'w_1008,h_567,c_fit',
      'portrait' => 'w_600,h_600,c_fill'
    }
    size = classes[name]
    "https://res.cloudinary.com/bssw/image/fetch/#{size}"
  end

  def self.get_title_chunk(doc)
    title_chunk = doc.at_css('h1') || doc.at_css('h2') || doc.at_css('h3')
    return unless title_chunk

    string = title_chunk.content.strip
    title_chunk.try(:remove)
    string
  end

  def self.add_caption(img)
    parent = img.parent
    caption = parent.try(:content).try(:match, Regexp.new(caption_regexp))
    return unless caption

    span = Nokogiri::XML::Node.new 'span', img.document
    span['class'] = 'caption'
    span.content = caption[1]
    parent.children.each do |child|
      replace_caption(child, caption, span)
    end
  end

  def self.replace_caption(child, caption, span)
    regexp = Regexp.escape(caption.to_s)
    content = child.content
    return unless content.match?(Regexp.new(regexp))

    child.replace(
      content.gsub(Regexp.new(regexp), span.to_xml.html_safe)
    )
  end

  def self.add_lightbox(img, src)
    new_size = 'w_1366,h_768,c_fit'
    big_src = "https://res.cloudinary.com/bssw/image/fetch/#{new_size}/#{src}"
    link = Nokogiri::XML::Node.new 'a', img.document
    link['href'] = big_src
    link['data-toggle'] = 'lightbox'
    link.inner_html = img.to_xml.html_safe
    img.replace(link)
  end

  def self.update_image(img, _doc)
    class_name = img['class'].to_s
    src = modified_path(img['src'])
    img['src'] = "#{image_classes(class_name)}#{src}" # adjusted_src
    add_caption(img)
    add_lightbox(img, src) if class_name.match('lightbox') # lb
  end

  def self.update_link(path)
    route = Rails.application.routes.url_helpers
    [SiteItem, Page, Community].each do |klass|
      item = klass.displayed.where(base_path: path).first
      return route.send("#{klass.name.underscore}_path", item) if item.try(:id)
    end
    path
  end

  def self.update_links(doc)
    doc.css('a').each do |link|
      href = link['href']
      next unless href&.match('\.md$') && !href.match('^http')

      href = href.split('/').last

      link['href'] = MarkdownUtility.update_link(href)
    end
  end

  def self.update_images(doc)
    doc.css('img').each do |img|
      MarkdownUtility.update_image(img, doc)
    end
  end
end
