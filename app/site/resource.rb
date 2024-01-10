# frozen_string_literal: true

# The basic Resource class
class Resource < SiteItem
  def self.unpublished_paths(rebuild_id)
    where(rebuild_id: rebuild_id,
                      publish: false).map(&:path).delete_if(&:blank?).join('<br />')
  end
end
