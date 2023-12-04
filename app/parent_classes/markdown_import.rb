# frozen_string_literal: true

# process markdown into content for site
class MarkdownImport < GithubImport
  require 'csv'
  self.abstract_class = true

  scope :displayed, lambda {
    where("#{table_name}.rebuild_id = ?", RebuildStatus.first.display_rebuild_id)
  }

  def update_links_and_images
    doc = Nokogiri::HTML.parse(content, nil, 'UTF-8')

    MarkdownUtility.update_links(doc)

    MarkdownUtility.update_images(doc)

    html = doc.to_html.to_s

    update_attribute(:content, html) unless content == html
  end

  def update_taxonomy(doc, rebuild)
    comments = doc.xpath('//comment()') if doc
    vals = comments.map { |comment| comment.text.split(/:|\n/) }.flatten
    array = vals.each do |val|
      val.strip || val
    end - ['-']
    array.delete_if(&:blank?)
    update_associates(array, rebuild)
  end

  def update_associates(array, _rebuild)
    array.each_cons(2) do |string, names|
      method = "add_#{string.strip}".downcase.tr(' ', '_')
      Rails.logger.debug method
      if method == 'add_topics'
        names = CSV.parse(names.gsub(/,\s+"/, ',"'), liberal_parsing: true).first
        save if new_record?
        try(:add_topics, names)
      elsif respond_to?(method, true)
        names = CSV.parse(names.gsub(/,\s+"/, ',"'), liberal_parsing: true).first
        send(method, names.join)
      end
    end
  end

  def add_opengraph_image(val)
    update_attribute(:open_graph_image_tag, MarkdownUtility.modified_path(val))
  end

  def add_rss_update(val)
    date = Chronic.parse(val)
    update_attribute(:rss_date, date)
  end

  def add_slug(val)
    self.custom_slug = val.downcase
    save
  end

  def add_aggregate(val)
    update_attribute(:aggregate, val) if has_attribute?(:aggregate)
  end

  def add_publish(val)
    val = val.strip.downcase
    if val.match('yes')
      update_attribute(:publish, true)
    else
      update_attribute(:publish, false)
    end
  end

  def add_pinned(val)
    update_attribute(:pinned, true) if val.downcase.match('y') && has_attribute?(:pinned)
  end

  def update_date(doc)
    return unless has_attribute?('published_at')

    node = doc.at("h4:contains('Publication date')")
    node ||= doc.at("h4:contains('Publication Date')")
    node ||= doc.at("h4:contains('publication date')")
    return unless node

    date = Chronic.parse(node.content.split(':').last)
    self.published_at = date
    node.try(:remove)
  end

  def dates(doc, rebuild)
    update_date(doc)
    return if !has_attribute?(:published_at) || is_a?(Event) || published_at.present?

    update_attribute(:published_at,
                     GithubImporter.github.commits(
                       Rails.application.credentials[:github][:repo],
                       rebuild.content_branch,
                       path: "/#{path}"
                     ).try(:first).try(:commit).try(:author).try(:date))
  end
end
