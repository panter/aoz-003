# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170420144523) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "has_vcards_addresses", force: :cascade do |t|
    t.string "post_office_box"
    t.string "extended_address"
    t.string "street_address"
    t.string "locality"
    t.string "region"
    t.string "postal_code"
    t.string "country_name"
    t.integer "vcard_id"
    t.string "address_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["vcard_id"], name: "addresses_vcard_id_index"
  end

  create_table "has_vcards_phone_numbers", force: :cascade do |t|
    t.string "number"
    t.string "phone_number_type"
    t.integer "vcard_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["phone_number_type"], name: "index_has_vcards_phone_numbers_on_phone_number_type"
    t.index ["vcard_id"], name: "phone_numbers_vcard_id_index"
  end

  create_table "has_vcards_vcards", force: :cascade do |t|
    t.string "full_name"
    t.string "nickname"
    t.string "family_name"
    t.string "given_name"
    t.string "additional_name"
    t.string "honorific_prefix"
    t.string "honorific_suffix"
    t.boolean "active", default: true
    t.string "type"
    t.integer "reference_id"
    t.string "reference_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["active"], name: "index_has_vcards_vcards_on_active"
    t.index ["reference_id", "reference_type"], name: "index_has_vcards_vcards_on_reference_id_and_reference_type"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.text "address"
    t.string "profession"
    t.boolean "monday"
    t.boolean "tuesday"
    t.boolean "wednesday"
    t.boolean "thursday"
    t.boolean "friday"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "role", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "profiles", "users"
end
