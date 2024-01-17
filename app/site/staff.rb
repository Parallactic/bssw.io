# frozen_string_literal: true

# to display on "about" page
# Author
class Staff < MarkdownImport
  scope :displayed, lambda {
    where("#{table_name}.rebuild_id = ?", RebuildStatus.first.display_rebuild_id)
  }

  def self.make_from_data(node, val, rebuild)
    node.css('a').each do |link|
      auth = Staff.find_or_create_by(website: link['href'], rebuild_id: rebuild)
      #      auth.update_attribute(:type, 'Staff')
      auth.update(section: val)
      auth.update_from_github
      Staff.find(auth.id).update_from_link(link.parent.children)
    end
  end

  def process_kid(kid)
    text = kid.text
    kid.remove if text.blank? || kid.name == 'br'
    update(title: text.gsub('Title: ', '')) if kid && text.match?('Title')
    kid.try(:remove)
  end

  def update_from_link(siblings)
    siblings.each do |kid|
      process_kid(kid)
    end
    names = AuthorUtility.names_from(siblings.first.text)
    update(first_name: names.first, last_name: names.last, alphabetized_name: names.last)
    update_affiliation(siblings)
  end

  def update_affiliation(siblings)
    if siblings[2].text.match('Title')
      update(affiliation:
                       siblings[4].text.strip)
    else
      update(affiliation:
                       siblings[2].text.strip)
    end
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
    # update(affiliation: hash.company) if affiliation.blank?
    # names = AuthorUtility.names_from(hash.name)
    # last_name = names.last
    # update(first_name: names.first, last_name: last_name, alphabetized_name: last_name) unless names == [nil, nil]
  end
end
