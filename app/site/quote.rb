# frozen_string_literal: true

# Quotes for rotating selection
class Quote < ApplicationRecord
  belongs_to :rebuild
  scope :displayed, lambda {
                      where("#{table_name}.rebuild_id = ?", RebuildStatus.displayed_rebuild)
                    }

  def self.import(content)
    doc = GithubImporter.parse_html_from(content)
    doc.css('li').each do |elem|
      list = elem.content.split('--')
      next if list.first.blank? || list.last.blank?

      q = Quote.find_or_create_by(text: list.first, author: list.last,
                                  rebuild_id: RebuildStatus.first.in_progress_rebuild_id)
      puts RebuildStatus.first.inspect
      puts RebuildStatus.first.in_progress_rebuild_id
      puts q.errors.inspect
    end
  end
end
