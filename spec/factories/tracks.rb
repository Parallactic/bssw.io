# frozen_string_literal: true

FactoryBot.define do
  factory :track do
    name { Faker::Name.first_name }
    rebuild
  end
end
