# frozen_string_literal: true

FactoryBot.define do
  factory :author do
    name { Faker::Name.first_name }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    website { Faker::Name.first_name }
    rebuild
  end
end
