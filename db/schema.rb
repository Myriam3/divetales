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

ActiveRecord::Schema[8.1].define(version: 2026_08_14_075119) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "categories", force: :cascade do |t|
    t.integer "classification", default: 0
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon_url"
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "countries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", limit: 150, null: false
    t.datetime "updated_at", null: false
  end

  create_table "dives", force: :cascade do |t|
    t.float "avg_depth"
    t.float "avg_temp"
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.text "depth_over_time", default: ""
    t.string "dive_site_name", default: "", null: false
    t.string "dive_types", default: [], array: true
    t.integer "duration"
    t.decimal "latitude"
    t.bigint "location_id", null: false
    t.decimal "longitude"
    t.float "max_depth"
    t.float "max_temp"
    t.float "min_temp"
    t.text "note"
    t.bigint "trip_id", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_dives_on_location_id"
    t.index ["trip_id"], name: "index_dives_on_trip_id"
  end

  create_table "locations", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.string "name", limit: 150, null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_locations_on_country_id"
  end

  create_table "picture_species", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "picture_id", null: false
    t.bigint "species_id", null: false
    t.datetime "updated_at", null: false
    t.index ["picture_id", "species_id"], name: "index_picture_species_on_picture_id_and_species_id", unique: true
    t.index ["picture_id"], name: "index_picture_species_on_picture_id"
    t.index ["species_id"], name: "index_picture_species_on_species_id"
  end

  create_table "pictures", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "date_time"
    t.bigint "dive_id", null: false
    t.datetime "updated_at", null: false
    t.index ["dive_id"], name: "index_pictures_on_dive_id"
  end

  create_table "species", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", limit: 150, null: false
    t.string "scientific_name", limit: 150
    t.string "tags", default: [], array: true
    t.datetime "updated_at", null: false
    t.string "wiki_link"
    t.index ["category_id"], name: "index_species_on_category_id"
  end

  create_table "trip_countries", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.bigint "trip_id", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_trip_countries_on_country_id"
    t.index ["trip_id"], name: "index_trip_countries_on_trip_id"
  end

  create_table "trips", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "end_date", null: false
    t.text "info"
    t.datetime "start_date", null: false
    t.string "title", limit: 150, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_trips_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "dives", "locations"
  add_foreign_key "dives", "trips"
  add_foreign_key "locations", "countries"
  add_foreign_key "picture_species", "pictures"
  add_foreign_key "picture_species", "species"
  add_foreign_key "pictures", "dives"
  add_foreign_key "species", "categories"
  add_foreign_key "trip_countries", "countries"
  add_foreign_key "trip_countries", "trips"
  add_foreign_key "trips", "users"
end
