# frozen_string_literal: true

FactoryBot.define do
  factory :topic do
    name { (0...8).map { rand(65..90).chr }.join }
    rebuild
    category
  end
end
