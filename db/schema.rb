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

ActiveRecord::Schema[8.1].define(version: 2026_03_15_194948) do
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

  create_table "availabilities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "day_of_week"
    t.time "end_time"
    t.time "start_time"
    t.bigint "tatoueur_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tatoueur_id"], name: "index_availabilities_on_tatoueur_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.text "cancellation_reason"
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.date "date"
    t.decimal "deposit_amount"
    t.datetime "deposit_confirmed_at"
    t.boolean "deposit_paid"
    t.datetime "deposit_paid_at"
    t.text "description"
    t.time "end_time"
    t.string "payment_method"
    t.string "paypal_order_id"
    t.string "paypal_payment_id"
    t.decimal "price_estimated"
    t.bigint "shop_id", null: false
    t.time "start_time"
    t.string "status"
    t.bigint "tatoueur_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["shop_id"], name: "index_bookings_on_shop_id"
    t.index ["tatoueur_id"], name: "index_bookings_on_tatoueur_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "conversation_participants", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.integer "participant_id"
    t.string "participant_type"
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_conversation_participants_on_conversation_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_participations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["event_id"], name: "index_event_participations_on_event_id"
    t.index ["user_id"], name: "index_event_participations_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "end_date"
    t.boolean "is_public"
    t.string "location"
    t.string "name"
    t.bigint "shop_id"
    t.datetime "start_date"
    t.bigint "tatoueur_id"
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_events_on_shop_id"
    t.index ["tatoueur_id"], name: "index_events_on_tatoueur_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "favoritable_id"
    t.string "favoritable_type"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "media", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.string "media_type"
    t.bigint "portfolio_item_id", null: false
    t.bigint "shop_id", null: false
    t.bigint "tatoueur_id", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["event_id"], name: "index_media_on_event_id"
    t.index ["portfolio_item_id"], name: "index_media_on_portfolio_item_id"
    t.index ["shop_id"], name: "index_media_on_shop_id"
    t.index ["tatoueur_id"], name: "index_media_on_tatoueur_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "read_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "portfolio_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "portfolio_id", null: false
    t.decimal "price"
    t.datetime "updated_at", null: false
    t.index ["portfolio_id"], name: "index_portfolio_items_on_portfolio_id"
  end

  create_table "portfolio_styles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "portfolio_item_id", null: false
    t.bigint "tattoo_style_id", null: false
    t.datetime "updated_at", null: false
    t.index ["portfolio_item_id"], name: "index_portfolio_styles_on_portfolio_item_id"
    t.index ["tattoo_style_id"], name: "index_portfolio_styles_on_tattoo_style_id"
  end

  create_table "portfolios", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.bigint "tatoueur_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tatoueur_id"], name: "index_portfolios_on_tatoueur_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.integer "rating"
    t.bigint "tatoueur_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["booking_id"], name: "index_reviews_on_booking_id"
    t.index ["tatoueur_id"], name: "index_reviews_on_tatoueur_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "shop_tatoueurs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date"
    t.bigint "shop_id", null: false
    t.date "start_date"
    t.bigint "tatoueur_id", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_shop_tatoueurs_on_shop_id"
    t.index ["tatoueur_id"], name: "index_shop_tatoueurs_on_tatoueur_id"
  end

  create_table "shops", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "email"
    t.boolean "is_active"
    t.float "latitude"
    t.float "longitude"
    t.string "name"
    t.string "open_hours"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_shops_on_user_id"
  end

  create_table "socials", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "platform"
    t.bigint "shop_id"
    t.bigint "tatoueur_id"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["shop_id"], name: "index_socials_on_shop_id"
    t.index ["tatoueur_id"], name: "index_socials_on_tatoueur_id"
  end

  create_table "tatoueur_styles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "tatoueur_id", null: false
    t.bigint "tattoo_style_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tatoueur_id"], name: "index_tatoueur_styles_on_tatoueur_id"
    t.index ["tattoo_style_id"], name: "index_tatoueur_styles_on_tattoo_style_id"
  end

  create_table "tatoueurs", force: :cascade do |t|
    t.string "address"
    t.string "bank_name"
    t.string "bic"
    t.datetime "created_at", null: false
    t.decimal "deposit_amount"
    t.text "description"
    t.string "email"
    t.string "first_name"
    t.string "iban"
    t.boolean "is_active"
    t.string "last_name"
    t.float "latitude"
    t.float "longitude"
    t.string "nickname"
    t.string "paypal_merchant_id"
    t.boolean "paypal_onboarded"
    t.string "siren"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.text "verification_rejected_reason"
    t.datetime "verification_reviewed_at"
    t.string "verification_status", default: "unsubmitted"
    t.datetime "verification_submitted_at"
    t.boolean "verified", default: false, null: false
    t.index ["user_id"], name: "index_tatoueurs_on_user_id"
  end

  create_table "tattoo_styles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.date "birth_date"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.boolean "is_active"
    t.string "last_name"
    t.string "nickname"
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "availabilities", "tatoueurs"
  add_foreign_key "bookings", "shops"
  add_foreign_key "bookings", "tatoueurs"
  add_foreign_key "bookings", "users"
  add_foreign_key "conversation_participants", "conversations"
  add_foreign_key "event_participations", "events"
  add_foreign_key "event_participations", "users"
  add_foreign_key "events", "shops"
  add_foreign_key "events", "tatoueurs"
  add_foreign_key "favorites", "users"
  add_foreign_key "media", "events"
  add_foreign_key "media", "portfolio_items"
  add_foreign_key "media", "shops"
  add_foreign_key "media", "tatoueurs"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "portfolio_items", "portfolios"
  add_foreign_key "portfolio_styles", "portfolio_items"
  add_foreign_key "portfolio_styles", "tattoo_styles"
  add_foreign_key "portfolios", "tatoueurs"
  add_foreign_key "reviews", "bookings"
  add_foreign_key "reviews", "tatoueurs"
  add_foreign_key "reviews", "users"
  add_foreign_key "shop_tatoueurs", "shops"
  add_foreign_key "shop_tatoueurs", "tatoueurs"
  add_foreign_key "shops", "users"
  add_foreign_key "socials", "shops"
  add_foreign_key "socials", "tatoueurs"
  add_foreign_key "tatoueur_styles", "tatoueurs"
  add_foreign_key "tatoueur_styles", "tattoo_styles"
  add_foreign_key "tatoueurs", "users"
end
