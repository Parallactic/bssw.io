# frozen_string_literal: true

# handle multiple dates for events, with and without specific labels
class AdditionalDateValue < ApplicationRecord
  belongs_to :additional_date
  delegate :event, to: :additional_date

  # scope :from_events, lambda { |events|
  #   joins(
  #     additional_date: 'event'
  #   ).includes([additional_date: :event]).where(
  #     'additional_dates.label not like ?', 'End '
  #   ).where('search_results.id in (?)', events.map(&:id))
  # }
end
