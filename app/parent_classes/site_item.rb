# frozen_string_literal: true

# resources, events, and blog posts

class SiteItem < SearchResult
  require 'csv'

  has_and_belongs_to_many :topics, -> { distinct }, join_table: 'site_items_topics', dependent: :destroy
  has_and_belongs_to_many :tracks, -> { distinct }, join_table: 'site_items_tracks'
  before_destroy { topics.clear }
  before_destroy { contributions.clear }
  has_many :contributions, join_table: 'contributions', dependent: :destroy
  has_many :authors, through: :contributions

  has_many :features

  def listed_tracks
    tracks.where(listed: true)
  end

  def rss_date
    super || published_at
  end

  def categories
    topics.map(&:category).uniq
  end

  def self.clean
    items = where(name: nil)
    items.each(&:delete)
  end
end
