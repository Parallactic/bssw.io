# frozen_string_literal: true

FactoryBot.define do
  factory :how_to do
    path { (0...8).map { rand(65..90).chr }.join }
    content { 'MyText' }
    type { 'HowTo' }
  end
end
