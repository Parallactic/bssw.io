# frozen_string_literal: true

FactoryBot.define do
  factory :subresource_relation do
    resource_id { 1 }
    subresource_id { 1 }
  end
end
