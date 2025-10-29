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

ActiveRecord::Schema[8.1].define(version: 2025_10_29_182836) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.string "name"
    t.json "properties"
    t.datetime "time", precision: nil
    t.integer "user_id"
    t.integer "visit_id"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "app_version"
    t.string "browser"
    t.string "city"
    t.string "country"
    t.string "device_type"
    t.string "ip"
    t.text "landing_page"
    t.float "latitude"
    t.float "longitude"
    t.string "organization_id"
    t.string "os"
    t.string "os_version"
    t.string "platform"
    t.text "referrer"
    t.string "referring_domain"
    t.string "region"
    t.datetime "started_at", precision: nil
    t.string "token_id"
    t.text "user_agent"
    t.integer "user_id"
    t.string "utm_campaign"
    t.string "utm_content"
    t.string "utm_medium"
    t.string "utm_source"
    t.string "utm_term"
    t.string "visit_token"
    t.string "visitor_token"
    t.index ["organization_id"], name: "index_ahoy_visits_on_organization_id"
    t.index ["token_id"], name: "index_ahoy_visits_on_token_id"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "allowlisted_jwts", force: :cascade do |t|
    t.string "aud"
    t.datetime "created_at"
    t.datetime "exp", precision: nil
    t.string "jti", null: false
    t.string "label"
    t.integer "resource_id"
    t.string "resource_type"
    t.string "scope", default: "all"
    t.datetime "updated_at"
    t.index ["jti"], name: "index_allowlisted_jwts_on_jti", unique: true
    t.index ["resource_type", "resource_id"], name: "index_allowlisted_jwts_on_resource_type_and_resource_id"
  end

  create_table "contact_emails", force: :cascade do |t|
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", null: false
    t.string "email"
    t.integer "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_contact_emails_on_confirmation_token", unique: true
    t.index ["organization_id"], name: "index_contact_emails_on_organization_id"
  end

  create_table "default_stream_histories", force: :cascade do |t|
    t.datetime "end_time"
    t.datetime "start_time", null: false
    t.integer "stream_id", null: false
    t.index ["stream_id"], name: "index_default_stream_histories_on_stream_id"
  end

  create_table "delta_dumps", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "effective_date"
    t.integer "normalized_dump_id", null: false
    t.integer "previous_stream_id"
    t.datetime "published_at"
    t.integer "stream_id", null: false
    t.datetime "updated_at", null: false
    t.index ["effective_date"], name: "index_delta_dumps_on_effective_date"
    t.index ["normalized_dump_id"], name: "index_delta_dumps_on_normalized_dump_id"
    t.index ["previous_stream_id"], name: "index_delta_dumps_on_previous_stream_id"
    t.index ["published_at"], name: "index_delta_dumps_on_published_at"
    t.index ["stream_id"], name: "index_delta_dumps_on_stream_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "full_dumps", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "effective_date"
    t.integer "normalized_dump_id", null: false
    t.datetime "published_at"
    t.integer "stream_id", null: false
    t.datetime "updated_at", null: false
    t.index ["effective_date"], name: "index_full_dumps_on_effective_date"
    t.index ["normalized_dump_id"], name: "index_full_dumps_on_normalized_dump_id"
    t.index ["published_at"], name: "index_full_dumps_on_published_at"
    t.index ["stream_id"], name: "index_full_dumps_on_stream_id"
  end

  create_table "group_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "group_id", null: false
    t.integer "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["organization_id"], name: "index_group_memberships_on_organization_id"
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.string "short_name"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_groups_on_slug", unique: true
  end

  create_table "job_trackers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "job_class"
    t.string "job_id"
    t.string "provider_job_id"
    t.integer "reports_on_id", null: false
    t.string "reports_on_type", null: false
    t.integer "resource_id", null: false
    t.string "resource_type", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_job_trackers_on_job_id"
    t.index ["provider_job_id"], name: "index_job_trackers_on_provider_job_id"
    t.index ["reports_on_type", "reports_on_id"], name: "index_job_trackers_on_reports_on_type_and_reports_on_id"
    t.index ["resource_type", "resource_id"], name: "index_job_trackers_on_resource_type_and_resource_id"
  end

  create_table "marc_profiles", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.json "field_frequency"
    t.json "histogram_frequency"
    t.json "record_frequency"
    t.json "sampled_values"
    t.datetime "updated_at", null: false
    t.integer "upload_id"
    t.index ["blob_id"], name: "index_marc_profiles_on_blob_id"
    t.index ["upload_id"], name: "index_marc_profiles_on_upload_id"
  end

  create_table "marc_records", force: :cascade do |t|
    t.bigint "bytecount"
    t.string "checksum"
    t.integer "file_id", null: false
    t.bigint "index"
    t.binary "json"
    t.bigint "length"
    t.string "marc001"
    t.string "status"
    t.integer "upload_id", null: false
    t.index ["file_id", "marc001"], name: "index_marc_records_on_file_id_and_marc001"
    t.index ["file_id"], name: "index_marc_records_on_file_id"
    t.index ["marc001", "upload_id"], name: "index_marc_records_on_marc001_and_upload_id"
    t.index ["upload_id", "marc001"], name: "index_marc_records_on_upload_id_and_marc001"
    t.index ["upload_id"], name: "index_marc_records_on_upload_id"
  end

  create_table "normalized_dumps", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "full_dump_id"
    t.datetime "last_delta_dump_at", precision: nil
    t.datetime "last_full_dump_at", precision: nil
    t.datetime "published_at"
    t.integer "stream_id", null: false
    t.datetime "updated_at", null: false
    t.index ["full_dump_id"], name: "index_normalized_dumps_on_full_dump_id"
    t.index ["stream_id"], name: "index_normalized_dumps_on_stream_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.string "marc_docs_url"
    t.string "name"
    t.json "normalization_steps"
    t.boolean "provider", default: true
    t.boolean "public", default: true
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "statistics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.bigint "file_count", default: 0
    t.bigint "file_size", default: 0
    t.bigint "record_count", default: 0
    t.integer "resource_id", null: false
    t.string "resource_type", null: false
    t.bigint "unique_record_count", default: 0
    t.datetime "updated_at", null: false
    t.index ["resource_type", "resource_id", "date"], name: "index_statistics_on_resource_type_and_resource_id_and_date"
    t.index ["resource_type", "resource_id"], name: "index_statistics_on_resource_type_and_resource_id"
  end

  create_table "streams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "default", default: false
    t.string "name"
    t.integer "organization_id"
    t.integer "previous_stream_id"
    t.string "slug"
    t.string "status", default: "active"
    t.datetime "updated_at", null: false
    t.index ["organization_id", "slug"], name: "index_streams_on_organization_id_and_slug", unique: true
    t.index ["organization_id"], name: "index_streams_on_organization_id"
    t.index ["previous_stream_id"], name: "index_streams_on_previous_stream_id"
    t.index ["status"], name: "index_streams_on_status"
  end

  create_table "uploads", force: :cascade do |t|
    t.integer "allowlisted_jwts_id"
    t.integer "compacted_upload_id"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.bigint "deletes_count", default: 0
    t.string "ip_address"
    t.bigint "marc_records_count", default: 0
    t.string "metadata_status"
    t.string "name"
    t.string "status", default: "active"
    t.integer "stream_id"
    t.bigint "total_byte_size", default: 0
    t.datetime "updated_at", null: false
    t.string "url"
    t.integer "user_id"
    t.index ["compacted_upload_id"], name: "index_uploads_on_compacted_upload_id"
    t.index ["status"], name: "index_uploads_on_status"
    t.index ["stream_id"], name: "index_uploads_on_stream_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "invitation_accepted_at", precision: nil
    t.datetime "invitation_created_at", precision: nil
    t.integer "invitation_limit"
    t.datetime "invitation_sent_at", precision: nil
    t.string "invitation_token"
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.string "name"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.string "title"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "versions", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "event", null: false
    t.integer "item_id", limit: 8, null: false
    t.string "item_type"
    t.text "object", limit: 1073741823
    t.text "object_changes", limit: 1073741823
    t.string "whodunnit"
    t.string "{null: false}"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "contact_emails", "organizations"
  add_foreign_key "default_stream_histories", "streams"
  add_foreign_key "delta_dumps", "normalized_dumps"
  add_foreign_key "full_dumps", "normalized_dumps"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "organizations"
end
