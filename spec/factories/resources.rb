# frozen_string_literal: true

FactoryBot.define do
  factory :resource do
    path { (0...8).map { rand(65..90).chr }.join }
    name { (0...8).map { rand(65..90).chr }.join }
    type { 'Resource' }
    publish { true }
    rebuild_id { RebuildStatus.first.display_rebuild_id }
    #    after(:create) { Resource.reindex }
  end
end
