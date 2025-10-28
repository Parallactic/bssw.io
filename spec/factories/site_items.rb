# frozen_string_literal: true

FactoryBot.define do
  factory :site_item do
    path { (0...8).map { rand(65..90).chr }.join }
    name { (0...8).map { rand(65..90).chr }.join }
    type { 'Resource' }
    aggregate { 'base' }
    publish { true }
    rebuild
  end
end
