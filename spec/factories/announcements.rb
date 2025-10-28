# frozen_string_literal: true

FactoryBot.define do
  factory :announcement do
    start_date { '2017-04-12' }
    end_date { '2017-04-12' }
    text { 'MyText' }
  end
end
