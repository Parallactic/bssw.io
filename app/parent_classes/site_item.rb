# frozen_string_literal: true

# resources, events, and blog posts

class SiteItem < SearchResult
  require 'csv'

  has_and_belongs_to_many :topics, -> { distinct }, join_table: 'site_items_topics', dependent: :destroy
  before_destroy { topics.clear }
  before_destroy { contributions.clear }
  has_many :contributions, join_table: 'contributions', dependent: :destroy
  has_many :authors, through: :contributions
  # has_and_belongs_to_many :communities, through: :features, class_name: 'Resource'

  has_many :features

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

  # def set_search_text
  #   text = ActionController::Base.helpers.strip_tags(
  #     " #{content.to_s.gsub('"', '')} #{try(:author_list)} #{name} #{try(:description)} #{try(:location)} #{try(:organizers)} ".downcase.gsub(/\s+/, " ")
  #   )
  #   #    puts text
  #   update(search_text: text)
  #   #    save
  # end
end
