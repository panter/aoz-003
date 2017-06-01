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

ActiveRecord::Schema.define(version: 20170601101842) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", force: :cascade do |t|
    t.string "permit"
    t.text "goals"
    t.string "state", default: "registered"
    t.text "comments"
    t.text "competent_authority"
    t.text "involved_authority"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_clients_on_deleted_at"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "contact_points", force: :cascade do |t|
    t.bigint "contact_id"
    t.string "body"
    t.string "label"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["contact_id"], name: "index_contact_points_on_contact_id"
    t.index ["deleted_at"], name: "index_contact_points_on_deleted_at"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name"
    t.string "street"
    t.string "extended"
    t.string "postal_code"
    t.string "city"
    t.string "contactable_type"
    t.bigint "contactable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["contactable_type", "contactable_id"], name: "index_contacts_on_contactable_type_and_contactable_id"
    t.index ["deleted_at"], name: "index_contacts_on_deleted_at"
  end

  create_table "departments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_departments_on_deleted_at"
  end

  create_table "departments_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "department_id", null: false
    t.index ["department_id", "user_id"], name: "index_departments_users_on_department_id_and_user_id"
  end

  create_table "language_skills", force: :cascade do |t|
    t.string "language"
    t.string "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "people_id"
    t.index ["deleted_at"], name: "index_language_skills_on_deleted_at"
    t.index ["people_id"], name: "index_language_skills_on_people_id"
  end

  create_table "nationalities", force: :cascade do |t|
    t.string "nation"
    t.bigint "people_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_nationalities_on_deleted_at"
    t.index ["people_id"], name: "index_nationalities_on_people_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "middle_name"
    t.string "title"
    t.string "gender"
    t.date "date_of_birth"
    t.text "education"
    t.text "hobbies"
    t.text "interests"
    t.string "profession"
    t.string "personable_type"
    t.bigint "personable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.index ["deleted_at"], name: "index_people_on_deleted_at"
    t.index ["personable_type", "personable_id"], name: "index_people_on_personable_type_and_personable_id"
  end

  create_table "people_relatives", id: false, force: :cascade do |t|
    t.bigint "relative_id", null: false
    t.bigint "person_id", null: false
    t.index ["person_id", "relative_id"], name: "index_people_relatives_on_person_id_and_relative_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_profiles_on_deleted_at"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "relatives", force: :cascade do |t|
    t.string "relation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "people_id"
    t.index ["deleted_at"], name: "index_relatives_on_deleted_at"
    t.index ["people_id"], name: "index_relatives_on_people_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.string "day"
    t.string "time"
    t.boolean "available", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "people_id"
    t.index ["deleted_at"], name: "index_schedules_on_deleted_at"
    t.index ["people_id"], name: "index_schedules_on_people_id"
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
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.integer "invited_by_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "volunteers", force: :cascade do |t|
    t.text "motivation"
    t.boolean "experience"
    t.text "expectations"
    t.text "strengths"
    t.text "skills"
    t.string "state", default: "interested/registered"
    t.string "duration"
    t.boolean "man"
    t.boolean "woman"
    t.boolean "family"
    t.boolean "kid"
    t.boolean "sport"
    t.boolean "creative"
    t.boolean "music"
    t.boolean "culture"
    t.boolean "training"
    t.boolean "german_course"
    t.boolean "adults"
    t.boolean "teenagers"
    t.boolean "children"
    t.string "region"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_volunteers_on_deleted_at"
  end

  add_foreign_key "clients", "users"
  add_foreign_key "contact_points", "contacts"
  add_foreign_key "profiles", "users"
end
