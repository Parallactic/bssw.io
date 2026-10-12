# frozen_string_literal: true

# created each time we run the GH import
class Rebuild < ApplicationRecord
  default_scope { order(created_at: 'desc') }
  has_many :site_items
  after_create :set_location
  attr_accessor :processed_files

  def set_location
    return if ip.blank?

    update(
      location: Geocoder.search(ip).try(:first).try(:data).try(:[], 'city')
    )
  end

  def self.in_progress
    !Rebuild.where('started_at > ?', 10.minutes.ago).to_a.select { |rebuild| rebuild.ended_at.blank? }.empty?
  end

  SKIP_PATHS = %w[utils/ test/ docs/].freeze

  def process_file(file)
    full_name = file.full_name
    return if SKIP_PATHS.any? { |s| full_name.include?(s) }

    ActiveRecord::Base.transaction(requires_new: true) do
      resource = process_path(full_name, file.read)
      resource.try(:save) if resource.try(:changed?)
      (@processed_files ||= []) << resource.try(:path)
      print '*'
    end
    rescue StandardError => e
      record_errors(File.basename(full_name), e)
  end

  def record_errors(file_name, error)
    update(errors_encountered:
             "#{errors_encountered}
                       <h4>#{file_name}:</h4>
                       <h5>#{error}</h5> #{error.backtrace.join('<br />')}<hr />")
  end

  def update_links_and_images
    (Page.all + SearchResult.all + Community.all
    ).each(&:update_links_and_images)
  end

  def clean(file_path)
    AuthorUtility.all_custom_info(id, file_path)
    clear_old

    update_links_and_images

    update(names: Author.display_names, unpublished_files: Resource.unpublished_paths(id))
    SearchResult.clear_index!
    SearchResult.displayed.reindex
    File.delete(file_path)
  end



  def clear_old
    keep_ids = (Rebuild.order(created_at: :desc).limit(5).pluck(:id) + [id]).uniq
    stale = ->(klass) { klass.where.not(rebuild_id: keep_ids).or(klass.where(rebuild_id: nil)) }
    conn  = ActiveRecord::Base.connection
    
    transaction do
      stale_items  = stale.(SearchResult).select(:id)   # covers Author, Fellow, Event, etc.
      stale_topics = stale.(Topic).select(:id)
      stale_events = stale.(Event).select(:id)
      stale_dates  = AdditionalDate.where(event_id: stale_events).select(:id)

      # 1. Grandchildren, then children, then join rows (parents still exist)
      AdditionalDateValue.where(additional_date_id: stale_dates).delete_all
      AdditionalDate.where(event_id: stale_events).delete_all
      FellowLink.where(fellow_id: stale_items).delete_all
      Contribution.where(site_item_id: stale_items)
                  .or(Contribution.where(author_id: stale_items))
                  .delete_all
      %w[site_items_topics site_items_tracks].each do |table|
        conn.execute("DELETE FROM #{table} WHERE site_item_id IN (#{stale_items.to_sql})")
      end
      conn.execute("DELETE FROM site_items_topics WHERE topic_id IN (#{stale_topics.to_sql})")

      # 2. Parents, one DELETE per table
      [SearchResult, Topic, Community, Category, Announcement,
       Quote, FeaturedPost, Page].each { |klass| stale.(klass).delete_all }
      Rebuild.where.not(id: keep_ids).delete_all
    end

    Contribution.clean
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

  def process_path(path, content)
    case path
    when /Quote/
      Quote.import(content)
    when /Announcements/
      Announcement.import(content, id)
    when /BlogTracks/
      Track.import(content, id)
    else
      process_resource(path, content)
    end
  end

  def process_resource(path, content)
    resource = find_or_create_resource(path)
    print '+'
    resource.parse_and_update(content)
    resource
  end

  def find_or_create_resource(path)
    normalized = GithubImporter.normalized_path(path)
    base       = File.basename(path)
    res        = resource_class_for(path)

    @resource_cache ||= {}
    @resource_cache[[res, normalized]] ||= begin
                                             item = res.find_or_create_by(path: normalized, rebuild_id: id) do |r|
                                               r.base_path = base # saved in the same INSERT
                                             end
                                             item.update(base_path: base) unless item.base_path == base # only for pre-existing rows that differ
                                             item
                                             
                                           end

  end

  def resource_class_for(path)
    matcher = self.class.file_structure_matchers.find { |regex, _| regex.match?(path) }
    matcher ? matcher.last : Page
  end

  def self.file_structure_matchers
    @file_structure_matchers ||= file_structure.map { |expr, klass| [Regexp.new(expr), klass] }
  end

  # def find_or_create_resource(path)
  #   res = Page
  #   Rebuild.file_structure.each do |expression, class_name|
  #     if path.match(Regexp.new(expression))
  #       res = class_name
  #       break
  #     end
  #   end
  #   item = res.find_or_create_by(path: GithubImporter.normalized_path(path), rebuild_id: id)

  #   item.update(base_path: File.basename(path))

  #   item
  # end
end
