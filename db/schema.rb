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

ActiveRecord::Schema[8.1].define(version: 2025_12_03_094015) do
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
    t.integer "service_id", null: false
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.string "virtual_host", null: false
    t.index ["app_id"], name: "index_instances_on_app_id"
    t.index ["environment"], name: "index_instances_on_environment"
    t.index ["service_id"], name: "index_instances_on_service_id"
    t.index ["tenant_id", "app_id", "environment"], name: "index_instances_on_tenant_app_environment", unique: true
    t.index ["tenant_id"], name: "index_instances_on_tenant_id"
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
    t.json "configuration"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
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
  add_foreign_key "identities", "users"
  add_foreign_key "instances", "apps"
  add_foreign_key "instances", "services"
  add_foreign_key "instances", "tenants"
  add_foreign_key "sessions", "users"
end
