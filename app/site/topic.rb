# frozen_string_literal: true

# Filters - like tags
class Topic < GithubImport
  #  default_scope -> { order(order_num: 'asc') }
  require 'csv'

  scope :displayed, lambda {
    where("#{table_name}.rebuild_id = ?", RebuildStatus.first.display_rebuild_id)
  }

  self.table_name = 'topics'
  has_and_belongs_to_many :site_items, -> { distinct }, join_table: 'site_items_topics'
  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false, scope: :rebuild_id
  belongs_to :category, optional: true
  before_destroy { site_items.clear }
  # after_save :update_resource_categories

  extend FriendlyId
  friendly_id :name, use: %i[finders history slugged scoped], scope: :rebuild_id

  def self.create_from_node(child, cat_id, rebuild_id)
    name = child.at('strong').content
    child.at('strong').remove
    topic = Topic.find_or_create_by(slug: name.parameterize, rebuild_id:)
    topic.update(overview: child.content, name: name.strip, order_num: topic.get_order(child),
                 category_id: cat_id)
    topic
  end

  def get_order(doc)
    comment = doc.at("//comment()[contains(.,'Topic order')]")
    return unless comment

    num = comment.text.match(/(\d+)/)
    comment.remove
    num.to_s.to_i
  end

  def self.from_name(top_name, rebuild_id)
    return if top_name.match(Regexp.new(/\[(.*)\]/))

    name = top_name.strip

    top = find_or_create_by(
      name: name,
      rebuild_id:
    )
    top.slug = name.parameterize
    top
  end
end
