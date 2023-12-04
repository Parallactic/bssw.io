# frozen_string_literal: true

class Track < GithubImport
  scope :displayed, lambda {
    where("#{table_name}.rebuild_id = ?", RebuildStatus.first.display_rebuild_id)
  }

  has_and_belongs_to_many :site_items, -> { distinct }, join_table: 'site_items_tracks'
  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false, scope: :rebuild_id

  extend FriendlyId
  friendly_id :name, use: %i[finders history slugged scoped], scope: :rebuild_id

  def self.import(content, rebuild_id)
    doc = GithubImporter.parse_html_from(content)
    doc.css('li').each do |elem|
      next if elem.text.blank?

      track = from_name(elem.text, rebuild_id)
      track.update(listed: true)
    end
  end

  def self.from_name(track_name, rebuild_id)
    return if track_name.match(Regexp.new(/\[(.*)\]/))

    name = track_name.strip.titleize

    track = find_or_create_by(
      name:,
      rebuild_id:
    )
    track.slug = name.parameterize
    track
  end
end
