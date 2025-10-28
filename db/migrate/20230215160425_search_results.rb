class SearchResults < ActiveRecord::Migration[6.0]
  def change
    create_table :search_results do |t|
      t.string "name"
      t.string "website"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "first_name"
      t.string "last_name"
      t.string "affiliation"
      t.string "avatar_url"
      t.string "type"
      t.boolean "cached_during_rebuild", default: false
      t.string "version_no"
      t.boolean "associate", default: false
      t.string "title"
      t.integer "rebuild_id"
      t.string "slug"
      t.integer "resource_count"
      t.integer "blog_count"
      t.integer "event_count"
      t.string "resource_listing"
      t.string "event_listing"
      t.string "blog_listing"
      t.string "section"
      t.string "alphabetized_name"
      t.text "search_text"
      t.string "year"

      t.string "image_path"
      t.string "url"
      t.string "linked_in"
      t.string "github"
      t.string "short_bio"
      t.text "long_bio"
      t.string "path"
      t.boolean "honorable_mention", default: false

      t.string "base_path"
      t.text "overview"
      t.text "content", size: :long

      t.datetime "published_at"

      t.string "aggregate"
      t.boolean "publish", default: false
      t.boolean "preview", default: false
      t.string "hero_image_url"
      t.text "hero_image_caption"
      t.date "rss_date"
      t.string "location"

      t.string "organizers"


      t.boolean "pinned", default: false
      t.integer "featured", default: 0
      t.integer "topics_count"



      t.text "topic_list"
      t.text "author_list"
      t.string "custom_slug"

      t.string "open_graph_image_tag"
      t.string "website_label"
      t.index ["name"], name: "index_search_results_on_name"
      t.index ["path"], name: "index_search_results_on_path"
      t.index ["rebuild_id"], name: "index_search_results_on_rebuild_id"
      t.index ["type"], name: "index_search_results_on_type"
    end
  end
end
