# frozen_string_literal: true

# for the homepage
class FeaturedPost < ApplicationRecord
  def self.displayed
    all.to_a.select { |fp| fp.rebuild_id == RebuildStatus.first.display_rebuild_id }
  end

  def image?
    path&.match(Regexp.new(/\.(gif|jpg|jpeg|tiff|png)$/i))
  end

  def image
    "<img src='#{MarkdownImport.modified_path(path)}' />".html_safe
    #    "<img src='https://github.com/betterscientificsoftware/#{path.gsub(' ', '')}' />".html_safe
  end

  def site_item
    SiteItem.find_by_slug(path.split('/').last)
  end
end
