# frozen_string_literal: true

# contributor of a resource
class Author < SearchResult
  self.table_name = 'search_results'

  include ActionView::Helpers::TextHelper

  has_many :contributions, autosave: false, join_table: 'contributions'
  has_many :search_results, through: :contributions, foreign_key: 'site_item_id'
  before_destroy { contributions.clear }

  extend FriendlyId
  friendly_id :slug_candidates, use: %i[finders slugged scoped], scope: %i[rebuild_id type]

  scope :displayed, lambda {
    where("#{table_name}.rebuild_id = ?", RebuildStatus.first.display_rebuild_id)
  }

  def should_generate_new_friendly_id?
    (new_record? || slug.blank?) && last_name.present?
  end

  def display_name
    "#{first_name} #{last_name}"
  end

  def name
    display_name
  end

  def single_contribution
    nums = [resource_count, event_count, blog_count]
    nums.sort == [0, 0, 1]
  end

  def resource_count
    SiteItem.published.displayed.with_author(self).size - blog_count - event_count
  end

  def blog_count
    BlogPost.published.displayed.with_author(self).size
  end

  def event_count
    Event.published.displayed.with_author(self).size
  end

  store_methods :resource_count, :blog_count, :event_count, :resource_listing, :blog_listing, :event_listing

  def resource_listing
    "#{resource_count} #{'resource'.pluralize(resource_count)}"
  end

  def blog_listing
    "#{blog_count} #{'blog post'.pluralize(blog_count)}"
  end

  def event_listing
    "#{event_count} #{'event'.pluralize(event_count)}"
  end

  def update_from_github
    return unless website&.match('github')
    return unless affiliation.blank? || avatar_url.blank?

    client = GithubImporter.github
    client.login
    begin
      update_info(client.user(website.split('/').last))
    rescue Octokit::NotFound
      # if we have an invalid GH id, don't worry about it
    end
  end

  def update_info(hash)
    update(avatar_url: hash.avatar_url.gsub(/\?v=[[:digit:]]/, ''))
    update(affiliation: hash.company) if affiliation.blank?
  end

  def do_overrides(alpha_name, display_name)
    return unless alpha_name

    update(alphabetized_name: alpha_name)
    return unless display_name

    names = AuthorUtility.names_from(display_name)
    update(first_name: names.first, last_name: names.last)
  end

  def self.find_from_vals(website, name, rebuild)
    if website == '-'
      names = AuthorUtility.names_from(name)
      find_by(rebuild_id: rebuild, first_name: names.first, last_name: names.last)
    else
      find_by(rebuild_id: rebuild, website: "https://github.com/#{website}")
    end
  end

  def cleanup
    if SiteItem.published.displayed.with_author(self).empty?
    #      delete
    else
      blog_listing
      resource_listing
      event_listing
    end
  end
end
