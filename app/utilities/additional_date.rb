# frozen_string_literal: true

# handle multiple dates for events
class AdditionalDate < ApplicationRecord
  belongs_to :event
  has_many :additional_date_values, dependent: :destroy

  include Dateable

  def self.make_date(label_text, dates, event)
    event.save

    if label_text.match('Start ') || label_text.match('End ')
      event.additional_dates.where(label: label_text).find_each(&:delete)
    end
    if label_text.match('[date]')
       label_text = label_text.gsub('[date]', '').strip
    end
    date = create(label: label_text, event:)
    dates.split(';').each do |datetime|
      date.additional_date_values << AdditionalDateValue.new(date: Chronic.parse(datetime).try(:to_date))
    end
  end

  def self.do_multiple_dates(dates, label_text, event)
    end_year = dates.last.match(/\d{4}/)
    dates = ["#{dates.first} #{end_year}", dates.last] unless dates.first.match(/\d{4}/)
    dates = month_dates(dates)
    AdditionalDate.make_date("Start #{label_text}", dates.first, event)
    AdditionalDate.make_date("End #{label_text}", dates.last, event)
  end

  def self.month_names
    Date::MONTHNAMES.slice(1..-1).map(&:to_s).map { |m| m[0, 3] }
  end

  def self.month_dates(dates)
    our_month, end_month = nil
    month_names.each do |month|
      our_month = month if dates.first.match(month)
      end_month = true if dates.last.match(month)
    end
    dates = [dates.first, "#{our_month} #{dates.last}"] if our_month && !end_month
    dates
  end
end
