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

  def self.from_name(top_name, rebuild_id)
    return if top_name.match(Regexp.new(/\[(.*)\]/))

    name = top_name.strip.downcase

    top = find_or_create_by(
      name:,
      rebuild_id:
    )
    top.slug = name.parameterize
    top
  end
end
