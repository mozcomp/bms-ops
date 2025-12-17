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

ActiveRecord::Schema[8.1].define(version: 2025_12_17_092340) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "apps", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "repository"
    t.datetime "updated_at", null: false
  end

  create_table "databases", force: :cascade do |t|
    t.json "connection"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "schema_version"
    t.datetime "updated_at", null: false
  end

  create_table "document_versions", force: :cascade do |t|
    t.text "change_summary"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.integer "document_id", null: false
    t.datetime "updated_at", null: false
    t.integer "version_number", null: false
    t.index ["created_by_id"], name: "index_document_versions_on_created_by_id"
    t.index ["document_id", "version_number"], name: "index_document_versions_on_document_id_and_version_number", unique: true
    t.index ["document_id"], name: "index_document_versions_on_document_id"
  end

  create_table "documents", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.text "excerpt"
    t.integer "folder_id"
    t.boolean "published", default: false
    t.string "slug", limit: 255, null: false
    t.string "title", limit: 255, null: false
    t.datetime "updated_at", null: false
    t.integer "updated_by_id", null: false
    t.string "visibility", default: "public", null: false
    t.index ["content"], name: "index_documents_on_content"
    t.index ["created_by_id"], name: "index_documents_on_created_by_id"
    t.index ["excerpt"], name: "index_documents_on_excerpt"
    t.index ["folder_id"], name: "index_documents_on_folder_id"
    t.index ["published", "visibility", "updated_at"], name: "index_documents_on_published_and_visibility_and_updated_at"
    t.index ["published"], name: "index_documents_on_published"
    t.index ["slug", "folder_id"], name: "index_documents_on_slug_and_folder_id", unique: true
    t.index ["title"], name: "index_documents_on_title"
    t.index ["updated_at"], name: "index_documents_on_updated_at"
    t.index ["updated_by_id"], name: "index_documents_on_updated_by_id"
    t.index ["visibility"], name: "index_documents_on_visibility"
  end

  create_table "folders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.text "description"
    t.string "name", limit: 255, null: false
    t.integer "parent_id"
    t.string "slug", limit: 255, null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_folders_on_created_by_id"
    t.index ["description"], name: "index_folders_on_description"
    t.index ["name"], name: "index_folders_on_name"
    t.index ["parent_id"], name: "index_folders_on_parent_id"
    t.index ["slug", "parent_id"], name: "index_folders_on_slug_and_parent_id", unique: true
  end

  create_table "health_checks", force: :cascade do |t|
    t.datetime "checked_at", null: false
    t.datetime "created_at", null: false
    t.json "details"
    t.string "name", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.index ["checked_at"], name: "index_health_checks_on_checked_at"
    t.index ["name", "checked_at"], name: "index_health_checks_on_name_and_checked_at"
    t.index ["name"], name: "index_health_checks_on_name"
    t.index ["status"], name: "index_health_checks_on_status"
  end

  create_table "identities", force: :cascade do |t|
    t.text "access_token"
    t.datetime "created_at", null: false
    t.string "provider"
    t.text "refresh_token"
    t.time "token_expires"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "instances", force: :cascade do |t|
    t.integer "app_id", null: false
    t.datetime "created_at", null: false
    t.json "env_vars"
    t.string "environment", null: false
    t.string "name", null: false
    t.integer "service_id", null: false
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.string "virtual_host", null: false
    t.index ["app_id"], name: "index_instances_on_app_id"
    t.index ["environment"], name: "index_instances_on_environment"
    t.index ["name"], name: "index_instances_on_name", unique: true
    t.index ["service_id"], name: "index_instances_on_service_id"
    t.index ["tenant_id", "app_id", "environment"], name: "index_instances_on_tenant_app_environment", unique: true
    t.index ["tenant_id"], name: "index_instances_on_tenant_id"
  end

  create_table "log_entries", force: :cascade do |t|
    t.json "context"
    t.datetime "created_at", null: false
    t.string "level", null: false
    t.text "message", null: false
    t.string "request_id"
    t.datetime "timestamp", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["level", "timestamp"], name: "index_log_entries_on_level_and_timestamp"
    t.index ["level"], name: "index_log_entries_on_level"
    t.index ["request_id", "timestamp"], name: "index_log_entries_on_request_id_and_timestamp"
    t.index ["request_id"], name: "index_log_entries_on_request_id"
    t.index ["timestamp"], name: "index_log_entries_on_timestamp"
    t.index ["user_id"], name: "index_log_entries_on_user_id"
  end

  create_table "metrics", force: :cascade do |t|
    t.string "aggregation_period"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.json "tags", default: {}
    t.datetime "timestamp", null: false
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 15, scale: 6, null: false
    t.index ["aggregation_period", "timestamp"], name: "index_metrics_on_aggregation_period_and_timestamp"
    t.index ["name", "timestamp"], name: "index_metrics_on_name_and_timestamp"
    t.index ["name"], name: "index_metrics_on_name"
    t.index ["timestamp"], name: "index_metrics_on_timestamp"
  end

  create_table "services", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "environment"
    t.string "image"
    t.string "name"
    t.string "registry"
    t.json "service_definition"
    t.string "service_task"
    t.string "string"
    t.json "task_definitions"
    t.datetime "updated_at", null: false
    t.string "version"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "code"
    t.string "contact"
    t.json "contact_details"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "user_bookmarks", force: :cascade do |t|
    t.datetime "bookmarked_at", null: false
    t.datetime "created_at", null: false
    t.integer "document_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["document_id"], name: "index_user_bookmarks_on_document_id"
    t.index ["user_id", "bookmarked_at"], name: "index_user_bookmarks_on_user_id_and_bookmarked_at"
    t.index ["user_id", "document_id"], name: "index_user_bookmarks_on_user_id_and_document_id", unique: true
    t.index ["user_id"], name: "index_user_bookmarks_on_user_id"
  end

  create_table "user_document_histories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "document_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.datetime "visited_at", null: false
    t.index ["document_id"], name: "index_user_document_histories_on_document_id"
    t.index ["user_id", "document_id"], name: "index_user_document_histories_on_user_id_and_document_id", unique: true
    t.index ["user_id", "visited_at"], name: "index_user_document_histories_on_user_id_and_visited_at"
    t.index ["user_id"], name: "index_user_document_histories_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "locale", default: "en", null: false
    t.string "password_digest", null: false
    t.string "timezone", default: "UTC", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "document_versions", "documents"
  add_foreign_key "document_versions", "users", column: "created_by_id"
  add_foreign_key "documents", "folders"
  add_foreign_key "documents", "users", column: "created_by_id"
  add_foreign_key "documents", "users", column: "updated_by_id"
  add_foreign_key "folders", "folders", column: "parent_id"
  add_foreign_key "folders", "users", column: "created_by_id"
  add_foreign_key "identities", "users"
  add_foreign_key "instances", "apps"
  add_foreign_key "instances", "services"
  add_foreign_key "instances", "tenants"
  add_foreign_key "sessions", "users"
  add_foreign_key "user_bookmarks", "documents"
  add_foreign_key "user_bookmarks", "users"
  add_foreign_key "user_document_histories", "documents"
  add_foreign_key "user_document_histories", "users"
end
