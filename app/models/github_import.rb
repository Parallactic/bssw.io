# frozen_string_literal: true

# methods that apply to all the stuff imorted from gh...
class GithubImport < ApplicationRecord
  self.abstract_class = true

  scope :displayed, lambda {
    where("#{table_name}.rebuild_id = ?", RebuildStatus.first.display_rebuild_id)
  }

  def self.excluded_filenames
    ['README.md', 'LICENSE', '.gitignore', 'Abbreviations.md', 'CODE_OF_CONDUCT.md', 'CONTRIBUTING.md', 'index.md']
  end

  def parse_and_update(content, rebuild_id)
    doc = Resource.parse_html_from(content)
    update_from_content(doc, rebuild_id)
    self
  end

  def update_from_content(doc, rebuild_id)
    title_chunk = GithubImport.get_title_chunk(doc)
    res = find_from_title(title_chunk)
    if res.has_attribute?(:published_at)
      res.update_date(doc)
      do_dates(res) unless res.is_a?(Event) || !res.published_at.blank?
    end

    res.update_taxonomy(doc, rebuild_id)

    content_string = doc.css('body').to_s + "\n<!-- file path: #{res.path} -->".html_safe
    res.update_attribute(:content, content_string)
  end

  def self.parse_html_from(updated_content)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
                                       autolink: true,
                                       tables: true,
                                       lax_spacing: true,
                                       disable_indented_code_blocks: true,
                                       fenced_code_blocks: true)
    Nokogiri::HTML(markdown.render(updated_content), nil, 'UTF-8')
  end

  def self.find_or_create_resource(path, rebuild_id)
    res = Page
    GithubImport.file_structure.each do |expression, class_name|
      if path.match(Regexp.new(expression))
        res = class_name
        break
      end
    end
    item = res.find_or_create_by(base_path: File.basename(path), rebuild_id: rebuild_id)
    item.update(path: normalized_path(path))
    item
  end

  def snippet
    pars = Nokogiri::HTML.parse(content, nil, 'UTF-8')
    pars.css('p').try(:first).to_s.html_safe
  end

  def main
    pars = Nokogiri::HTML.parse(content, nil, 'UTF-8')
    pars.css('p').try(:first).try(:remove)
    pars.to_s.html_safe
  end

  def self.file_structure # rubocop:disable Metrics/MethodLength
    {
      'CuratedContent/WhatIs' => WhatIs,
      'CuratedContent/WhatAre' => WhatIs,
      'CuratedContent/HowTo' => HowTo,
      'Articles/WhatIs' => WhatIs,
      'Articles/WhatAre' => WhatIs,
      'Articles/HowTo' => HowTo,
      'Site/Topic' => Category,
      '/People/' => Fellow,
      'Site/Communities/..+.md' => Community,
      'Site/' => Page,
      'Events' => Event,
      'Blog/' => BlogPost,
      'Articles/' => Resource,
      'CuratedContent/' => Resource
    }
  end

  def self.normalized_path(path)
    new_path = path.split('/')
    new_path.shift
    new_path.join('/')
  end

  def self.process_path(path, content, rebuild)
    return if path.match('utils/') || path.match('test/') || path.match('docs/') || content.nil?

    if path.match('Quote')
      Quote.import(content)
    elsif path.match('Announcements')
      Announcement.import(content, rebuild)
    else
      resource = find_or_create_resource(path, rebuild)
      resource.parse_and_update(content, rebuild)
      #      resource
    end
  end

  def self.github
    Octokit::Client.new(access_token: Rails.application.credentials[:github][:token])
  end

  def self.agent
    agent = Mechanize.new
    agent.pluggable_parser.default = Mechanize::Download
    agent
  end

  def self.tar_extract(file_path)
    tar = Gem::Package::TarReader.new(Zlib::GzipReader.open(file_path))
    tar.rewind
    tar
  end

  def self.get_title_chunk(doc)
    title_chunk = (doc.at_css('h1') || doc.at_css('h2') || doc.at_css('h3'))
    return unless title_chunk

    string = title_chunk.content.strip
    title_chunk.try(:remove)
    string
  end

  def find_from_title(string)
    res = self.class.find_by(name: string, rebuild_id: rebuild_id) || self
    res.name = string
    res.save
    res
  end
end
