# frozen_string_literal: true

# bios etc for fellows
class Fellow < SearchResult
  scope :displayed, lambda {
    where("#{table_name}.rebuild_id = ?", RebuildStatus.first.display_rebuild_id)
  }

  self.table_name = 'search_results'

  extend FriendlyId
  friendly_id :slug_candidates, use: %i[finders slugged scoped], scope: %i[rebuild_id type honorable_mention]

  has_many :fellow_links, dependent: :destroy

  before_save :sluggos

  def sluggos
    return unless name

    s = Fellow.where(slug: name.try(:parameterize), rebuild_id:).first
    if s && s != self
      begin
        s.update(:slug, nil)
      rescue StandardError
        # skip if problems
      end
    end
    self.slug = name.try(:parameterize).force_encoding('UTF-8')
  end

  def last_name
    name.try(:split).try(:last).to_s
  end

  def set_hm
    update(honorable_mention: base_path.to_s.match?('HM'))
  end

  def modified_path
    MarkdownUtility.modified_path(image_path)
  end

  def update_from_content(doc, _rebuild)
    fellow_links.each(&:destroy)
    set_hm
    save
    update_details(doc)
  end

  def update_details(doc)
    doc.css('a.link-row').each do |link|
      FellowLink.create(url: link['href'], text: link.content, fellow_id: id)
      link.try(:remove)
    end
    do_fields(doc)
    node = doc.at("strong:contains('Long Bio')")
    node.try(:remove)

    send('long_bio=', doc.to_html)
    save
  end

  private

  def fields
    { 'Short Bio' => 'short_bio',
      'Year' => 'year',
      'Name' => 'name',
      'Affiliation' => 'affiliation',
      'Image' => 'image_path',
      'URL' => 'url',
      'LinkedIn' => 'linked_in',
      'Github' => 'github' }
  end

  def do_fields(doc)
    fields.each do |name, meth|
      node = doc.at("strong:contains('#{name}')")
      par = node.try(:parent)
      node.try(:remove)
      fix_italics(par)
      send("#{meth}=", par.try(:content))
      par.try(:remove)
      save
    end
  end

  def fix_italics(par)
    return unless par.respond_to?(:children)

    par.children.each do |p|
      p.replace("\_#{p.text}\_") if p.name == 'em'
    end
  end
end
