# frozen_string_literal: true

FactoryBot.define do
  factory :community do
    name { 'MyString' }
    content { 'MyText' }
    path { 'myPath' }
  end
end
