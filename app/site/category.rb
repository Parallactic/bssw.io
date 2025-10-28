# frozen_string_literal: true

# resource has one Category
class Category < MarkdownImport
  #  has_and_belongs_to_many :resources, -> { distinct }
  has_many :topics, -> { order(order_num: 'asc') }

  default_scope -> { order(order_num: 'asc') }
  self.table_name = 'categories'

  extend FriendlyId
  friendly_id :name, use: %i[finders slugged scoped], scope: :rebuild_id

  def should_generate_new_friendly_id?
    true
  end

  def update_from_content(doc, rebuild_id)
    save
    update(get_details(doc).merge(order_num: get_order(doc)))
    update_topics(doc, rebuild_id)
    super(doc, rebuild_id)
  end

  private

  def get_order(doc)
    return unless doc

    comment = doc.at("//comment()[contains(.,'Category order')]")
    return unless comment

    num = comment.text.match(/(\d+)/)
    comment.remove
    num.to_s.to_i
  end

  def get_details(doc)
    deets = {}
    %w[overview homepage].each do |attr|
      node = doc.at("strong:contains('#{attr.titleize}')")
      next unless node

      deets[attr] = node.parent
      node.remove
    end
    deets
  end

  def update_topics(doc, rebuild)
    node = doc.at("strong:contains('Topics')")
    doc.css('li').each do |child|
      process_topic(child, rebuild.try(:id))
      child.remove
    end
    node.remove
  end

  def process_topic(child, rebuild_id)
    save
    Topic.create_from_node(child, id, rebuild_id)
  end
end
