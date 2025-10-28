# frozen_string_literal: true

FactoryBot.define do
  factory :page do
    name { 'MyString' }
    content { 'MyText' }
    path { (0...8).map { rand(65..90).chr }.join }
    publish { true }
    rebuild
  end
end
