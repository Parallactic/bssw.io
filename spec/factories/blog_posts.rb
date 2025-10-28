# frozen_string_literal: true

FactoryBot.define do
  factory :blog_post do
    path { (1...8).map { rand(65..90).chr }.join }
    name { (1...8).map { rand(65..90).chr }.join }
    publish { true }
    aggregate { 'base' }

    type { 'BlogPost' }
    rebuild
  end
end
