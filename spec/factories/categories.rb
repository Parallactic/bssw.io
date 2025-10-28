# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    name { "Category #{rand(100)}" }
    rebuild
  end
end
