# frozen_string_literal: true

# Events e.g. conferences
class Event < SiteItem
  include Dateable
  has_many :additional_dates, dependent: :destroy
  has_many :additional_date_values, -> { order(date: :asc) }, through: :additional_dates

  scope :upcoming, lambda {
    left_outer_joins(:additional_dates).includes(:additional_date_values).where(
      'additional_date_values.date >= ?',
      Time.zone.today
    ).order('additional_date_values.date asc')
  }

  scope :past, lambda {
    left_outer_joins(:additional_dates).includes(:additional_date_values).where(
      'additional_date_values.date < ?',
      Time.zone.today
    ).order('additional_date_values.date desc')
  }

  def next_date
    additional_date_values.joins(:additional_date).where('date >= ?', Time.zone.today).first
  end

  def prev_date
    additional_date_values.joins(:additional_date).where('date < ?', Time.zone.today).where(
      'additional_dates.label not LIKE ?', '%End %'
    ).last
  end

  def start_date
    additional_dates.where('label LIKE ?', '%Start %').first
  end

  def start_at
    start_date.try(:additional_date_values).try(:first).try(:date)
  end

  def end_date
    additional_dates.where('label LIKE ?', '%End %').first
  end

  def end_at
    end_date.try(:additional_date_values).try(:first).try(:date)
  end

  def update_from_content(doc, rebuild)
    update_details(doc)
    overview = doc.at("p:contains('Overview')")
    overview&.remove
    super(doc, rebuild)
  end

  def special_additional_dates
    additional_date_values.where('additional_date_id in (?)',
                                 additional_dates.where('label not LIKE ?', '%Start %').where('label not LIKE ?',
                                                                                              '%End %').map(&:id))
  end

  private

  def update_details(doc)
    %w[location organizers].each do |method|
      node = doc.at("li:contains('#{method.titleize}')")
      send("#{method}=", node.text.split(':').last) if node
      node.try(:remove)
    end
    if doc.at("li:contains('Website')")
      do_website(doc.at("li:contains('Website')"))
      #      self.website = "http:#{website}" if website
    end
    update_dates(doc)
    doc.at("strong:contains('Description')").try(:remove)
  end

  def do_website(node)
    url = node.text
    match = url.match('\[(.*?)\](.*)')
    if match
      update(website_label: match[1], website: match[2])
    else
      self.website = (url.split(':').last)
    end
    node.try(:remove)
  end

  def update_dates(doc)
    get_date_nodes(doc).each do |date_node|
      text_node = Loofah.xml_fragment(date_node.text)
      text_node.scrub!(:prune)
      text = text_node.text.split(':')
      process_dates(text.last, text.first) if text.last
      date_node.try(:remove)
    end
    fix_end_year(start_date, end_date)
  end

  def get_date_nodes(doc)
    doc.css("li:contains('Date')") +
      doc.css("li:contains(' date')") +
      doc.css("li:contains('Deadline')") +
      doc.css("li:contains('deadline')")
  end

  def process_dates(date_text, label_text)
    dates = if date_text.match(/\d{1,2}-\d{1,2}-\d{2,4}/)
              date_text.split('- ')
            else
              date_text.split('-')
            end
    if dates.size > 1
      AdditionalDate.do_multiple_dates(dates, label_text, self)
    else
      AdditionalDate.make_date(label_text, date_text, self)
    end
  end
end
