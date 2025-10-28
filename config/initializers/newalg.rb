# frozen_string_literal: true

AlgoliaSearch.configuration = {
  application_id: Rails.application.credentials[:algolia][:application_id],
  api_key: Rails.application.credentials[:algolia][:api_key],
  pagination_backend: :will_paginate
}
