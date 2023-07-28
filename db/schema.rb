# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_07_24_160537) do
  create_table "acronyms", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "additional_date_values", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "date", precision: nil
    t.integer "additional_date_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "additional_dates", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "label"
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "announcements", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.text "text"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "resource_id"
    t.integer "blog_post_id"
    t.integer "event_id"
    t.boolean "cached_during_rebuild", default: false
    t.integer "site_item_id"
    t.string "version_no"
    t.integer "rebuild_id"
    t.string "path"
  end

  create_table "authors", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "website"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.index ["rebuild_id"], name: "index_authors_on_rebuild_id"
  end

  create_table "authors_resources", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "author_id"
    t.integer "resource_id"
  end

  create_table "categories", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "content"
    t.string "path"
    t.text "overview"
    t.text "quote"
    t.integer "what_is_id"
    t.integer "how_to_id"
    t.integer "order_num"
    t.text "description"
    t.boolean "cached_during_rebuild", default: false
    t.string "version_no"
    t.text "homepage"
    t.integer "rebuild_id"
    t.string "slug"
    t.string "base_path"
  end

  create_table "categories_resources", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "category_id"
    t.integer "resource_id"
  end

  create_table "children_parents", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "parent_id"
    t.integer "child_id"
  end

  create_table "communities", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "content"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "path"
    t.boolean "publish"
    t.boolean "cached_during_rebuild", default: false
    t.string "version_no"
    t.text "resource_paths"
    t.integer "rebuild_id"
    t.string "slug"
    t.string "base_path"
    t.index ["path"], name: "index_communities_on_path"
    t.index ["rebuild_id"], name: "index_communities_on_rebuild_id"
  end

  create_table "communities_resources", id: false, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "resource_id", null: false
    t.integer "community_id", null: false
    t.index ["community_id", "resource_id"], name: "index_communities_resources_on_community_id_and_resource_id"
    t.index ["resource_id", "community_id"], name: "index_communities_resources_on_resource_id_and_community_id"
  end

  create_table "contributions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "author_id"
    t.integer "site_item_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "order", default: 1
    t.string "display_name"
    t.index ["author_id"], name: "index_contributions_on_author_id"
    t.index ["site_item_id"], name: "index_contributions_on_site_item_id"
  end

  create_table "delayed_jobs", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "events", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "version_no"
  end

  create_table "events_resources", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "event_id"
    t.integer "resource_id"
  end

  create_table "featured_posts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "label"
    t.string "path"
    t.integer "rebuild_id"
  end

  create_table "features", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "resource_id"
    t.integer "community_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "order", default: 1
  end

  create_table "fellow_links", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "fellow_id"
    t.string "url"
    t.string "text"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "fellows", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "year"
    t.string "name"
    t.string "affiliation"
    t.string "image_path"
    t.string "url"
    t.string "linked_in"
    t.string "github"
    t.string "short_bio"
    t.text "long_bio"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "path"
    t.boolean "honorable_mention", default: false
    t.integer "rebuild_id"
    t.string "slug"
    t.text "search_text"
    t.string "base_path"
  end

  create_table "friendly_id_slugs", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at", precision: nil
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope"
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", length: { slug: 140 }
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "github_imports", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "how_tos", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "category_id"
    t.string "title"
    t.text "content"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "path"
  end

  create_table "pages", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "content"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "path"
    t.boolean "publish"
    t.boolean "cached_during_rebuild", default: false
    t.string "version_no"
    t.integer "rebuild_id"
    t.string "slug"
    t.string "base_path"
    t.string "open_graph_image_tag"
    t.index ["path"], name: "index_pages_on_path"
    t.index ["rebuild_id"], name: "index_pages_on_rebuild_id"
  end

  create_table "quotes", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "text"
    t.string "author"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "cached_during_rebuild", default: false
    t.integer "rebuild_id"
  end

  create_table "rebuild_statuses", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "display_rebuild_id"
    t.integer "in_progress_rebuild_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "code_branch"
  end

  create_table "rebuilds", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "ip"
    t.datetime "started_at", precision: nil
    t.datetime "ended_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "version_no"
    t.string "location"
    t.text "files_processed"
    t.text "errors_encountered"
    t.string "content_branch"
    t.string "commit_hash"
    t.text "names"
  end

  create_table "resources", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "overview"
    t.text "content"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "path"
    t.string "name"
    t.datetime "published_at", precision: nil
    t.string "slug"
    t.string "type"
    t.string "aggregate", default: "base"
    t.boolean "publish", default: false
    t.string "hero_image_url"
    t.string "hero_image_caption"
    t.date "rss_date"
    t.boolean "preview", default: false
    t.string "location"
    t.string "website"
    t.string "organizers"
    t.date "end_at"
    t.date "start_at"
    t.boolean "cached_during_rebuild", default: false
    t.string "version_no"
  end

  create_table "resources_topics", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "topic_id"
    t.integer "resource_id"
    t.index ["resource_id"], name: "index_resources_topics_on_resource_id"
    t.index ["topic_id"], name: "index_resources_topics_on_topic_id"
  end

  create_table "search_results", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "website"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "published_at", precision: nil
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
    t.boolean "is_person", default: false
    t.index ["name"], name: "index_search_results_on_name"
    t.index ["path"], name: "index_search_results_on_path"
    t.index ["rebuild_id"], name: "index_search_results_on_rebuild_id"
    t.index ["type"], name: "index_search_results_on_type"
  end

  create_table "site_items", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "overview"
    t.text "content", size: :long
    t.string "path"
    t.string "name"
    t.datetime "published_at", precision: nil
    t.string "type"
    t.string "aggregate"
    t.boolean "publish", default: false
    t.boolean "preview", default: false
    t.string "hero_image_url"
    t.text "hero_image_caption"
    t.date "rss_date"
    t.string "location"
    t.string "website"
    t.string "organizers"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "version_no"
    t.boolean "pinned", default: false
    t.integer "featured", default: 0
    t.integer "topics_count"
    t.text "search_text"
    t.integer "rebuild_id"
    t.string "slug"
    t.text "topic_list"
    t.text "author_list"
    t.string "custom_slug"
    t.string "base_path"
    t.string "open_graph_image_tag"
    t.string "website_label"
    t.index ["name"], name: "index_site_items_on_name"
    t.index ["path"], name: "index_site_items_on_path"
    t.index ["rebuild_id"], name: "index_site_items_on_rebuild_id"
    t.index ["type"], name: "index_site_items_on_type"
  end

  create_table "site_items_topics", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "topic_id"
    t.integer "site_item_id"
  end

  create_table "site_items_tracks", id: false, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "track_id", null: false
    t.bigint "site_item_id", null: false
    t.index ["site_item_id", "track_id"], name: "index_site_items_tracks_on_site_item_id_and_track_id"
  end

  create_table "staffs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "section"
    t.string "affiliation"
    t.string "first_name"
    t.string "last_name"
    t.text "search_text"
    t.integer "rebuild_id"
    t.string "avatar_url"
    t.string "title"
    t.string "alphabetized_name"
  end

  create_table "subresource_relations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "subresource_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "order", default: 1
    t.integer "parent_resource_id"
  end

  create_table "taggings", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "topics", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "category_id"
    t.text "overview"
    t.text "description"
    t.boolean "cached_during_rebuild", default: false
    t.string "version_no"
    t.integer "order_num"
    t.integer "rebuild_id"
    t.string "slug"
    t.index ["name"], name: "index_topics_on_name"
    t.index ["rebuild_id"], name: "index_topics_on_rebuild_id"
  end

  create_table "tracks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
  end

  create_table "what_is", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "category_id"
    t.text "content"
    t.string "title"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "path"
  end

end
