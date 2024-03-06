# frozen_string_literal: true

# plain content
class Page < Resource
  scope :displayed, lambda {
    where("#{table_name}.rebuild_id = ?", RebuildStatus.first.display_rebuild_id)
  }

  validates_presence_of :path, :name
  validates_uniqueness_of :path, case_sensitive: false, scope: :rebuild_id
  scope :published, -> { where(publish: true) }

  self.table_name = 'search_results'

  extend FriendlyId
  friendly_id :name, use: %i[finders slugged scoped], scope: :rebuild_id

  def regular
    name != 'Contact BSSw' &&
      name != 'Resources' &&
      name != 'Upcoming Events' &&
      name != 'Past Events'
  end

  def home?
    slug == 'homepage'
  end

  def update_from_content(doc, rebuild)
    self.slug = nil
    update_featured(doc) if path.match('Homepage')
    update_staff(doc) if path.match('About')
    super(doc, rebuild)
    self.slug = 'homepage' if path.match('Home')
    save
  end

  def self.names_to_pages(names)
    names.map do |name|
      find_by(name:, rebuild_id: RebuildStatus.first.display_rebuild_id)
    end.delete_if(&:!)
  end

  def self.orientation
    names_to_pages(['Communities Overview',
                    'Intro To CSE',
                    'Intro To HPC'])
  end

  def self.fellows
    names_to_pages(['BSSw Fellowship Program',
                    'Apply for the BSSw Fellowship Program',
                    'Meet Our Fellows',
                    'BSSw Fellowship FAQ'])
  end

  def self.contribute
    names_to_pages(
      ['What To Contribute: Content for Better Scientific Software',
       'How To Contribute Content to Better Scientific Software',
       'Questions About Contributing to Better Scientific Software?']
    )
  end

  def update_staff(doc)
    start_node = doc.css('h2')[0]

    return unless start_node

    node = start_node.next_element
    start_node.remove if start_node.text == 'BSSw Editorial Team'
    while node

      update_staffers(doc, node) if doc.css('h3').index(node)
      old_node = node
      node = old_node.next_element
      old_node.remove if doc.css('h3').index(old_node) || old_node.text.blank?
    end
  end

  def update_staffers(doc, node)
    val = node.text
    node = node.next_element

    while node

      break if doc.css('h2').index(node) || doc.css('h3').index(node)

      Staff.make_from_data(node, val, rebuild_id)
      old_node = node
      node = old_node.next_element
      #      old_node.remove
    end
  end

  def update_featured(doc)
    node = doc.at("//comment()[contains(.,'Slide1')]")
    return unless node

    node.text.split("\n").map do |slide|
      slide_info = slide.split(':')
      path = slide_info.last
      FeaturedPost.create(path:, label: slide_info.first, rebuild_id:) unless path == '-'
    end
    node.remove
  end
end
