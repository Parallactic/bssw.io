# frozen_string_literal: true

FactoryBot.define do
  factory :fellow do
    name { Faker::Name.first_name }
    year { Time.zone.today.year }
    path { "/fellows/#{Faker::Name.first_name}.md" }
    long_bio { Faker::Lorem.paragraph }
  end
end
