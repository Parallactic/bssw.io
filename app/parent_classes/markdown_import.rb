# frozen_string_literal: true

# process markdown into content for site
class MarkdownImport < GithubImport
  require 'csv'
  self.abstract_class = true

  scope :displayed, lambda {
    where("#{table_name}.rebuild_id = ?", RebuildStatus.display_rebuild_id)
  }

  def update_links_and_images
    return if content.blank?

    doc = Nokogiri::HTML.parse(content, nil, 'UTF-8')

    MarkdownUtility.update_links(doc)

    MarkdownUtility.update_images(doc)

    html = doc.to_html.to_s
    Rails.logger.debug ">>> rewrite #{self.class.name} id=#{id} rebuild_id=#{rebuild_id} imgs=#{doc.css('img').size}"
    #    content = html
    update!(content: html) unless content == html
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
      new_names = CSV.parse(names.gsub(/,\s+"/, ',"'), liberal_parsing: true).first
      case method
      when 'add_track'
        try(:add_track, names)
      when 'add_topics'
        save if new_record?
        try(:add_topics, new_names)
      else
        send(method, new_names.join) if respond_to?(method, true)
      end
    end
  end

  def add_opengraph_image(val)
    update(open_graph_image_tag: MarkdownUtility.modified_path(val))
  end

  def add_rss_update(val)
    date = Chronic.parse(val)
    update(rss_date: date)
  end

  def add_slug(val)
    self.custom_slug = val.downcase.strip
    save
  end

  def add_alias(val)
    self.alias = val.downcase.strip
    save
  end

  def add_aggregate(val)
    update(aggregate: val) if has_attribute?(:aggregate)
  end

  def add_publish(val)
    val = val.strip.downcase
    if val.match('yes')
      update(publish: true)
    else
      update(publish: false)
    end
  end

  def add_pinned(val)
    update(pinned: true) if val.downcase.match('y') && has_attribute?(:pinned)
  end

  def update_date(doc)
    return unless has_attribute?('published_at')

    node = doc.at("h4:contains('Publication date')")
    node ||= doc.at("h4:contains('Publication Date')")
    node ||= doc.at("h4:contains('publication date')")
    return unless node

    date = Chronic.parse(node.content.split(':').last)
    update(published_at: date)
    node.try(:remove)
  end

  def dates(doc, rebuild)
    update_date(doc)
    return if !has_attribute?(:published_at) || is_a?(Event) || published_at.present?

    update_published(rebuild)
  end

  def update_published(rebuild)
    update(published_at:
             GithubImporter.github.commits(
               Rails.application.credentials[:github][:repo],
               rebuild.content_branch,
               path: "/#{path}",
               per_page: 1
             ).try(:first).try(:commit).try(:author).try(:date))
  end

  def add_topics(names)
    found = names.filter_map do |top_name|
      next if top_name.blank?

      Topic.from_name(top_name.strip.delete_prefix('"').delete_suffix('"'), rebuild_id)
    end

    new_topics = found.uniq - topics.to_a
    topics << new_topics if new_topics.any?
  end

  def add_track(names)
    names.split(',').each do |name|
      tracks << Track.from_name(name.strip.gsub(/^"/, '').gsub(/"$/, ''),
                                rebuild_id)
    end
  end

  def basic?
    is_a?(WhatIs) || is_a?(HowTo)
  end
end
