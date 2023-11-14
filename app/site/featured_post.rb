# frozen_string_literal: true

# for the homepage
class FeaturedPost < ApplicationRecord
  def self.displayed
    all.to_a.select { |fp| fp.rebuild_id == RebuildStatus.first.display_rebuild_id }
  end

  def image?
    path.strip.match(Regexp.new(/\.(gif|jpg|jpeg|tiff|png)$/i))
  end

  def image
    "<img src='#{MarkdownUtility.modified_path(path)}' />".html_safe
  end

  def site_item
    SiteItem.displayed.find_by(base_path: File.basename(path.to_s)) ||
      SiteItem.displayed.find_by(slug: path.to_s.split('/').last)
  end
end
