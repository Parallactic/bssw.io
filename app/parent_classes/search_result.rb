# frozen_string_literal: true

# searchable thru algolia
class SearchResult < MarkdownImport


  def author_list_without_links
    if authors.empty?
      ActionController::Base.helpers.content_tag('strong', 'By').concat ' BSSw Community'
    else
      ActionController::Base.helpers.content_tag('strong', 'By').concat contributions.map(&:display_name).to_sentence
    end
  end

  
include AlgoliaSearch

  algoliasearch per_environment: true, sanitize: true, auto_index: false, if: :searchable? do
    attributes :name, :content, :author_list_without_links, :published_at
    searchableAttributes %w[name author_list_without_links content]
    attributesToSnippet %w[content]
    attributesToHighlight %w[name author_list_without_links]
    highlightPreTag '<mark>'
    highlightPostTag '</mark>'
    hitsPerPage 1000
    ranking ['typo', 'desc(is_fellow)', 'desc(published_at)']
    advancedSyntax true
  end

  # def searchable_content
  #   ActionView::Base.full_sanitizer.sanitize(content).gsub("\n", ' ').gsub(',', '')
  # end

  extend FriendlyId
  friendly_id :slug_candidates, use: %i[finders slugged scoped], scope: :rebuild_id

  def slug_candidates
    if custom_slug.blank?
      if honorable_mention
        'none'
      else
        name
      end
    else
      custom_slug
    end
  end

  def resolve_friendly_id_conflict(candidates)
    if rebuild && candidates.first
      rebuild.slug_collisions = rebuild.slug_collisions.to_s + "<li><strong>Slug:</strong> #{candidates.first.inspect}  <strong>Filename of item trying to use slug:</strong> #{base_path} <br /><strong>Filename of conflicting item:</strong> #{SearchResult.where(
        rebuild_id:, slug: candidates.first.to_s
      ).first.base_path}</li>"

      rebuild.save
    end
    super
  end

  def should_generate_new_friendly_id?
    custom_slug_changed? || name_changed? || super
  end

  def searchable?
    (publish || (is_a?(Fellow) && !honorable_mention)) && rebuild_id == RebuildStatus.first.display_rebuild_id
  end

  scope :published, lambda {
    where(publish: true)
  }

  scope :with_topic, lambda { |topic|
    joins([:topics]).where('topics.id = ?', topic) if topic.present?
  }

  scope :with_track, lambda { |track|
                       joins([:tracks]).where('tracks.id = ?', track) if track.present?
                     }

  scope :with_category, lambda { |category|
    joins([:topics]).joins([:searchresults_topics]).where('topics.category_id = ?', category)
  }

  scope :with_author, lambda { |author|
    joins([:contributions]).where('contributions.author_id = ?', author.id)
  }

  scope :events, lambda {
    where(type: 'Event')
  }

  scope :blog, lambda {
    where(type: 'BlogPost').order('published_at desc')
  }

  scope :rss, lambda {
    where.not(rss_date: nil).or(
      where.not(published_at: nil).where(
        'published_at > ?', Chronic.parse('June 1 2018').to_s
      )
    ).order(Arel.sql('coalesce(rss_date, published_at) desc')).first(15)
  }

  scope :standard_scope, lambda { |_all = false|
    distinct.order(Arel.sql('(case when pinned then 1 else 0 end) DESC, name ASC'))
  }

  has_and_belongs_to_many :topics, lambda {
    distinct
  }, join_table: 'site_items_topics', dependent: :destroy, foreign_key: 'site_item_id'
  has_and_belongs_to_many :tracks, join_table: 'site_items_tracks', foreign_key: 'site_item_id'
  before_destroy { topics.clear }
  before_destroy { contributions.clear }
  has_many :contributions, join_table: 'contributions', dependent: :destroy, foreign_key: 'site_item_id'
  has_many :authors, through: :contributions

  has_many :features, foreign_key: 'site_item_id'

  validates :path, uniqueness: { case_sensitive: false, scope: :rebuild_id, allow_blank: true }

  has_many :announcements, foreign_key: 'site_item_id'
end
