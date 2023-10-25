# frozen_string_literal: true

# methods that apply to all the stuff imorted from gh...
class GithubImport < ApplicationRecord
  self.abstract_class = true

  belongs_to :rebuild

  def parse_and_update(content)
    content_string = content.dup.force_encoding('UTF-8').encode!
    doc = GithubImporter.parse_html_from(content_string)
    update_from_content(doc, rebuild)
    self
  end

  def update_from_content(doc, rebuild)
    save
    title_chunk = MarkdownUtility.get_title_chunk(doc)
    update(name: title_chunk.try(:strip))
    dates(doc, rebuild)
    update_author(doc.at("h4:contains('Contributed')"), rebuild_id) unless is_a?(Page)
    update_taxonomy(doc, rebuild)

    content_string = doc.css('body').to_s + "\n<!-- file path: #{path} -->".html_safe
    update_attribute(:content, content_string)
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

  # def find_from_title(string, path)
  #   res = self.class.find_by(name: string, rebuild_id: rebuild_id, path: path) || self
  #   res.name = string
  #   res.save
  #   res
  # end

  def update_author(node, rebuild)
    return unless node && respond_to?('authors')

    auths = AuthorUtility.make_from_data(
      node, rebuild
    )
    auths.each do |auth|
      if auth.first.is_a?(Author)
        contributions << Contribution.create(author: auth.first, display_name: auth.last.strip)
      end
    end
    node.try(:remove)
  end
end
