# frozen_string_literal: true

# handle multiple dates for events, with and without specific labels
class AdditionalDateValue < ApplicationRecord
  belongs_to :additional_date
  delegate :event, to: :additional_date

  scope :from_events, lambda { |events|
    joins(
      additional_date: 'event'
    ).includes([additional_date: :event]).where(
      'additional_dates.label not like ?', 'End '
    ).where('search_results.id in (?)', events.map(&:id))
  }

  # def self.get_from_events(events, past)
  #   values = from_events(events)
  #   date_groups = values.group_by { |d| [d.additional_date.event_id, d.additional_date.label] }
  #   date_groups.each do |dg|
  #     next if dg.last.size == 1

  #     dates = process_date_group(dg, past)
  #     values = values.where('additional_date_values.id not in (?)', dates.map(&:id))
  #   end
  #   values
  # end

  # def self.process_date_group(group, past)
  #   puts "past #{past}"
  #   puts "start size #{group.last.size}"
  #   new_date = if past
  #                group.last.select { |d| d.date < Date.today }.max_by(&:date)
  #              else
  #                group.last.select { |d| d.date >= Date.today }.min_by(&:date)
  #              end
  #   group = group.last.to_a - [new_date]
  #   puts "end size #{group.size}"
  #   group
  # end
end
