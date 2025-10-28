# frozen_string_literal: true

FactoryBot.define do
  factory :additional_date_value do
    date { 3.weeks.ago }
    additional_date
  end
end
