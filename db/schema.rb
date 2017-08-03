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

ActiveRecord::Schema.define(version: 20170803113154) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.bigint "client_id"
    t.bigint "volunteer_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state"
    t.bigint "creator_id"
    t.index ["client_id"], name: "index_assignments_on_client_id"
    t.index ["creator_id"], name: "index_assignments_on_creator_id"
    t.index ["volunteer_id"], name: "index_assignments_on_volunteer_id"
  end

  create_table "clients", force: :cascade do |t|
    t.date "birth_year"
    t.string "nationality"
    t.string "permit"
    t.string "salutation"
    t.text "goals"
    t.text "education"
    t.text "interests"
    t.string "state", default: "registered"
    t.text "comments"
    t.text "competent_authority"
    t.text "involved_authority"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.date "entry_year"
    t.string "gender_request"
    t.string "age_request"
    t.string "other_request"
    t.text "actual_activities"
    t.index ["deleted_at"], name: "index_clients_on_deleted_at"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "street"
    t.string "extended"
    t.string "postal_code"
    t.string "city"
    t.string "contactable_type"
    t.bigint "contactable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "first_name"
    t.string "last_name"
    t.string "title"
    t.string "primary_email"
    t.string "primary_phone"
    t.string "secondary_phone"
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

  create_table "imports", force: :cascade do |t|
    t.bigint "access_id"
    t.jsonb "store"
    t.string "importable_type"
    t.bigint "importable_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_id"], name: "index_imports_on_access_id"
    t.index ["deleted_at"], name: "index_imports_on_deleted_at"
    t.index ["importable_type", "importable_id"], name: "index_imports_on_importable_type_and_importable_id"
  end

  create_table "journals", force: :cascade do |t|
    t.string "subject"
    t.bigint "user_id"
    t.text "body"
    t.string "journalable_type"
    t.bigint "journalable_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_journals_on_deleted_at"
    t.index ["journalable_type", "journalable_id"], name: "index_journals_on_journalable_type_and_journalable_id"
    t.index ["user_id"], name: "index_journals_on_user_id"
  end

  create_table "language_skills", force: :cascade do |t|
    t.bigint "languageable_id"
    t.string "language"
    t.string "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "languageable_type"
    t.index ["deleted_at"], name: "index_language_skills_on_deleted_at"
    t.index ["languageable_type", "languageable_id"], name: "index_language_skills_on_languageable_type_and_languageable_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id"
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
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_profiles_on_deleted_at"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "relatives", force: :cascade do |t|
    t.bigint "relativeable_id"
    t.string "first_name"
    t.string "last_name"
    t.date "birth_year"
    t.string "relation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "relativeable_type"
    t.index ["deleted_at"], name: "index_relatives_on_deleted_at"
    t.index ["relativeable_type", "relativeable_id"], name: "index_relatives_on_relativeable_type_and_relativeable_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.bigint "scheduleable_id"
    t.string "day"
    t.string "time"
    t.boolean "available", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "scheduleable_type"
    t.index ["deleted_at"], name: "index_schedules_on_deleted_at"
    t.index ["scheduleable_type", "scheduleable_id"], name: "index_schedules_on_scheduleable_type_and_scheduleable_id"
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

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "volunteer_emails", force: :cascade do |t|
    t.string "subject"
    t.string "title"
    t.text "body"
    t.bigint "user_id"
    t.boolean "active"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_volunteer_emails_on_deleted_at"
    t.index ["user_id"], name: "index_volunteer_emails_on_user_id"
  end

  create_table "volunteers", force: :cascade do |t|
    t.date "birth_year"
    t.string "salutation"
    t.string "nationality"
    t.string "additional_nationality"
    t.string "profession"
    t.text "education"
    t.text "motivation"
    t.boolean "experience"
    t.text "expectations"
    t.text "strengths"
    t.text "interests"
    t.string "state", default: "registered"
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
    t.boolean "teenagers"
    t.boolean "children"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.bigint "user_id"
    t.string "rejection_type"
    t.text "rejection_text"
    t.string "working_percent"
    t.text "volunteer_experience_desc"
    t.bigint "registrar_id"
    t.boolean "trial_period", default: false
    t.boolean "intro_course", default: false
    t.boolean "doc_sent", default: false
    t.boolean "bank_account", default: false
    t.boolean "evaluation", default: false
    t.boolean "dancing"
    t.boolean "health"
    t.boolean "cooking"
    t.boolean "excursions"
    t.boolean "women"
    t.boolean "unaccompanied"
    t.boolean "zurich"
    t.boolean "other_offer"
    t.text "other_offer_desc"
    t.text "own_kids"
    t.boolean "flexible", default: false
    t.boolean "morning", default: false
    t.boolean "afternoon", default: false
    t.boolean "evening", default: false
    t.boolean "workday", default: false
    t.boolean "weekend", default: false
    t.text "detailed_description"
    t.index ["deleted_at"], name: "index_volunteers_on_deleted_at"
    t.index ["user_id"], name: "index_volunteers_on_user_id"
  end

  add_foreign_key "assignments", "clients"
  add_foreign_key "assignments", "users", column: "creator_id"
  add_foreign_key "assignments", "volunteers"
  add_foreign_key "clients", "users"
  add_foreign_key "journals", "users"
  add_foreign_key "profiles", "users"
  add_foreign_key "volunteer_emails", "users"
  add_foreign_key "volunteers", "users"
end
