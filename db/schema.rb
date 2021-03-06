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

ActiveRecord::Schema.define(version: 20181004121332) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignment_logs", force: :cascade do |t|
    t.bigint "assignment_id"
    t.bigint "volunteer_id"
    t.bigint "client_id"
    t.bigint "creator_id"
    t.bigint "period_end_set_by_id"
    t.bigint "termination_submitted_by_id"
    t.bigint "termination_verified_by_id"
    t.date "period_start"
    t.date "period_end"
    t.datetime "performance_appraisal_review"
    t.datetime "probation_period"
    t.datetime "home_visit"
    t.datetime "first_instruction_lesson"
    t.datetime "progress_meeting"
    t.string "short_description"
    t.text "goals"
    t.text "starting_topic"
    t.text "description"
    t.string "kind", default: "accompaniment"
    t.datetime "submitted_at"
    t.datetime "termination_submitted_at"
    t.datetime "termination_verified_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "term_feedback_activities"
    t.text "term_feedback_success"
    t.text "term_feedback_problems"
    t.text "term_feedback_transfair"
    t.text "comments"
    t.text "additional_comments"
    t.string "assignment_description"
    t.string "first_meeting"
    t.string "frequency"
    t.string "trial_period_end"
    t.string "duration"
    t.string "special_agreement"
    t.text "agreement_text"
    t.bigint "submitted_by_id"
    t.index ["assignment_id"], name: "index_assignment_logs_on_assignment_id"
    t.index ["client_id"], name: "index_assignment_logs_on_client_id"
    t.index ["creator_id"], name: "index_assignment_logs_on_creator_id"
    t.index ["deleted_at"], name: "index_assignment_logs_on_deleted_at"
    t.index ["period_end"], name: "index_assignment_logs_on_period_end"
    t.index ["period_end_set_by_id"], name: "index_assignment_logs_on_period_end_set_by_id"
    t.index ["period_start"], name: "index_assignment_logs_on_period_start"
    t.index ["submitted_at"], name: "index_assignment_logs_on_submitted_at"
    t.index ["submitted_by_id"], name: "index_assignment_logs_on_submitted_by_id"
    t.index ["termination_submitted_at"], name: "index_assignment_logs_on_termination_submitted_at"
    t.index ["termination_submitted_by_id"], name: "index_assignment_logs_on_termination_submitted_by_id"
    t.index ["termination_verified_at"], name: "index_assignment_logs_on_termination_verified_at"
    t.index ["termination_verified_by_id"], name: "index_assignment_logs_on_termination_verified_by_id"
    t.index ["volunteer_id"], name: "index_assignment_logs_on_volunteer_id"
  end

  create_table "assignments", force: :cascade do |t|
    t.bigint "client_id"
    t.bigint "volunteer_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "creator_id"
    t.date "period_start"
    t.date "period_end"
    t.datetime "performance_appraisal_review"
    t.datetime "probation_period"
    t.datetime "home_visit"
    t.datetime "first_instruction_lesson"
    t.datetime "progress_meeting"
    t.string "short_description"
    t.text "goals"
    t.text "starting_topic"
    t.text "description"
    t.string "kind", default: "accompaniment"
    t.datetime "submitted_at"
    t.bigint "period_end_set_by_id"
    t.datetime "termination_submitted_at"
    t.bigint "termination_submitted_by_id"
    t.datetime "termination_verified_at"
    t.bigint "termination_verified_by_id"
    t.text "term_feedback_activities"
    t.text "term_feedback_success"
    t.text "term_feedback_problems"
    t.text "term_feedback_transfair"
    t.text "comments"
    t.text "additional_comments"
    t.string "assignment_description"
    t.string "first_meeting"
    t.string "frequency"
    t.string "trial_period_end"
    t.string "duration"
    t.string "special_agreement"
    t.text "agreement_text", default: "Freiwillige beachten folgende Grundsätze während ihres Einsatzes in der AOZ:\n* Verhaltenskodex für Freiwillige\n* Rechte und Pflichten für Freiwillige\n* AOZ Leitlinien Praktische Integrationsarbeit\n\nAllenfalls auch\n* Verpflichtungserklärung zum Schutz der unbegleiteten minderjährigen Asylsuchenden (MNA)\n* Niederschwellige Gratis-Deutschkurse: Informationen für freiwillige Kursleitende\n"
    t.string "pdf_file_name"
    t.string "pdf_content_type"
    t.integer "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.bigint "submitted_by_id"
    t.index ["client_id"], name: "index_assignments_on_client_id"
    t.index ["creator_id"], name: "index_assignments_on_creator_id"
    t.index ["period_end"], name: "index_assignments_on_period_end"
    t.index ["period_end_set_by_id"], name: "index_assignments_on_period_end_set_by_id"
    t.index ["period_start"], name: "index_assignments_on_period_start"
    t.index ["submitted_at"], name: "index_assignments_on_submitted_at"
    t.index ["submitted_by_id"], name: "index_assignments_on_submitted_by_id"
    t.index ["termination_submitted_at"], name: "index_assignments_on_termination_submitted_at"
    t.index ["termination_submitted_by_id"], name: "index_assignments_on_termination_submitted_by_id"
    t.index ["termination_verified_at"], name: "index_assignments_on_termination_verified_at"
    t.index ["termination_verified_by_id"], name: "index_assignments_on_termination_verified_by_id"
    t.index ["volunteer_id"], name: "index_assignments_on_volunteer_id"
  end

  create_table "billing_expenses", force: :cascade do |t|
    t.integer "amount"
    t.string "bank"
    t.string "iban"
    t.bigint "volunteer_id"
    t.bigint "user_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "overwritten_amount"
    t.index ["deleted_at"], name: "index_billing_expenses_on_deleted_at"
    t.index ["user_id"], name: "index_billing_expenses_on_user_id"
    t.index ["volunteer_id"], name: "index_billing_expenses_on_volunteer_id"
  end

  create_table "certificates", force: :cascade do |t|
    t.integer "hours"
    t.date "duration_start"
    t.date "duration_end"
    t.text "institution"
    t.text "text_body"
    t.string "function"
    t.jsonb "volunteer_contact"
    t.jsonb "assignment_kinds"
    t.bigint "volunteer_id"
    t.bigint "user_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "creator_name"
    t.string "creator_function"
    t.index ["deleted_at"], name: "index_certificates_on_deleted_at"
    t.index ["user_id"], name: "index_certificates_on_user_id"
    t.index ["volunteer_id"], name: "index_certificates_on_volunteer_id"
  end

  create_table "client_notifications", force: :cascade do |t|
    t.text "body"
    t.bigint "user_id"
    t.boolean "active"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_client_notifications_on_deleted_at"
    t.index ["user_id"], name: "index_client_notifications_on_user_id"
  end

  create_table "clients", force: :cascade do |t|
    t.date "birth_year"
    t.string "nationality"
    t.string "permit"
    t.string "salutation"
    t.text "goals"
    t.text "education"
    t.text "interests"
    t.text "comments"
    t.text "competent_authority"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "gender_request"
    t.string "age_request"
    t.string "other_request"
    t.text "actual_activities"
    t.boolean "flexible", default: false
    t.boolean "morning", default: false
    t.boolean "afternoon", default: false
    t.boolean "evening", default: false
    t.boolean "workday", default: false
    t.boolean "weekend", default: false
    t.text "detailed_description"
    t.string "entry_date"
    t.integer "acceptance", default: 0
    t.integer "cost_unit"
    t.bigint "involved_authority_id"
    t.bigint "resigned_by_id"
    t.datetime "resigned_at"
    t.datetime "accepted_at"
    t.datetime "rejected_at"
    t.text "additional_comments"
    t.index ["acceptance"], name: "index_clients_on_acceptance"
    t.index ["accepted_at"], name: "index_clients_on_accepted_at"
    t.index ["birth_year"], name: "index_clients_on_birth_year"
    t.index ["deleted_at"], name: "index_clients_on_deleted_at"
    t.index ["involved_authority_id"], name: "index_clients_on_involved_authority_id"
    t.index ["nationality"], name: "index_clients_on_nationality"
    t.index ["rejected_at"], name: "index_clients_on_rejected_at"
    t.index ["resigned_at"], name: "index_clients_on_resigned_at"
    t.index ["resigned_by_id"], name: "index_clients_on_resigned_by_id"
    t.index ["salutation"], name: "index_clients_on_salutation"
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
    t.string "primary_email"
    t.string "primary_phone"
    t.string "secondary_phone"
    t.boolean "external", default: false
    t.string "full_name"
    t.index ["contactable_type", "contactable_id"], name: "index_contacts_on_contactable_type_and_contactable_id"
    t.index ["deleted_at"], name: "index_contacts_on_deleted_at"
    t.index ["external"], name: "index_contacts_on_external"
    t.index ["full_name"], name: "index_contacts_on_full_name"
    t.index ["postal_code"], name: "index_contacts_on_postal_code"
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

  create_table "email_templates", force: :cascade do |t|
    t.string "subject"
    t.text "body"
    t.integer "kind", default: 0
    t.boolean "active"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_email_templates_on_deleted_at"
  end

  create_table "event_volunteers", force: :cascade do |t|
    t.bigint "volunteer_id"
    t.bigint "event_id"
    t.bigint "creator_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_event_volunteers_on_creator_id"
    t.index ["deleted_at"], name: "index_event_volunteers_on_deleted_at"
    t.index ["event_id"], name: "index_event_volunteers_on_event_id"
    t.index ["volunteer_id"], name: "index_event_volunteers_on_volunteer_id"
  end

  create_table "events", force: :cascade do |t|
    t.integer "kind", null: false
    t.date "date"
    t.time "start_time"
    t.time "end_time"
    t.string "title"
    t.text "description"
    t.bigint "department_id"
    t.bigint "creator_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "speaker"
    t.index ["creator_id"], name: "index_events_on_creator_id"
    t.index ["deleted_at"], name: "index_events_on_deleted_at"
    t.index ["department_id"], name: "index_events_on_department_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.text "goals"
    t.text "achievements"
    t.text "future"
    t.text "comments"
    t.boolean "conversation"
    t.datetime "deleted_at"
    t.bigint "volunteer_id"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "feedbackable_type"
    t.bigint "feedbackable_id"
    t.bigint "reviewer_id"
    t.bigint "responsible_id"
    t.datetime "responsible_at"
    t.index ["author_id"], name: "index_feedbacks_on_author_id"
    t.index ["deleted_at"], name: "index_feedbacks_on_deleted_at"
    t.index ["feedbackable_type", "feedbackable_id"], name: "index_feedbacks_on_feedbackable_type_and_feedbackable_id"
    t.index ["responsible_id"], name: "index_feedbacks_on_responsible_id"
    t.index ["reviewer_id"], name: "index_feedbacks_on_reviewer_id"
    t.index ["volunteer_id"], name: "index_feedbacks_on_volunteer_id"
  end

  create_table "group_assignment_logs", force: :cascade do |t|
    t.bigint "group_offer_id"
    t.bigint "volunteer_id"
    t.bigint "group_assignment_id"
    t.string "title"
    t.date "period_start"
    t.date "period_end"
    t.boolean "responsible", default: false
    t.datetime "deleted_at"
    t.bigint "period_end_set_by_id"
    t.bigint "termination_submitted_by_id"
    t.bigint "termination_verified_by_id"
    t.datetime "termination_submitted_at"
    t.datetime "termination_verified_at"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "term_feedback_activities"
    t.text "term_feedback_success"
    t.text "term_feedback_problems"
    t.text "term_feedback_transfair"
    t.text "comments"
    t.text "additional_comments"
    t.string "place"
    t.text "description"
    t.string "happens_at"
    t.string "frequency"
    t.string "trial_period_end"
    t.text "agreement_text"
    t.bigint "submitted_by_id"
    t.index ["deleted_at"], name: "index_group_assignment_logs_on_deleted_at"
    t.index ["group_assignment_id"], name: "index_group_assignment_logs_on_group_assignment_id"
    t.index ["group_offer_id"], name: "index_group_assignment_logs_on_group_offer_id"
    t.index ["period_end_set_by_id"], name: "index_group_assignment_logs_on_period_end_set_by_id"
    t.index ["submitted_by_id"], name: "index_group_assignment_logs_on_submitted_by_id"
    t.index ["termination_submitted_by_id"], name: "index_group_assignment_logs_on_termination_submitted_by_id"
    t.index ["termination_verified_by_id"], name: "index_group_assignment_logs_on_termination_verified_by_id"
    t.index ["title"], name: "index_group_assignment_logs_on_title"
    t.index ["volunteer_id"], name: "index_group_assignment_logs_on_volunteer_id"
  end

  create_table "group_assignments", force: :cascade do |t|
    t.bigint "group_offer_id"
    t.bigint "volunteer_id"
    t.date "period_start"
    t.date "period_end"
    t.boolean "responsible", default: false
    t.datetime "deleted_at"
    t.datetime "submitted_at"
    t.bigint "period_end_set_by_id"
    t.bigint "termination_submitted_by_id"
    t.bigint "termination_verified_by_id"
    t.datetime "termination_submitted_at"
    t.datetime "termination_verified_at"
    t.text "term_feedback_activities"
    t.text "term_feedback_success"
    t.text "term_feedback_problems"
    t.text "term_feedback_transfair"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comments"
    t.text "additional_comments"
    t.string "place"
    t.text "description"
    t.string "happens_at"
    t.string "frequency"
    t.string "trial_period_end"
    t.text "agreement_text", default: "Freiwillige beachten folgende Grundsätze während ihres Einsatzes in der AOZ:\n* Verhaltenskodex für Freiwillige\n* Rechte und Pflichten für Freiwillige\n* AOZ Leitlinien Praktische Integrationsarbeit\n\nAllenfalls auch\n* Verpflichtungserklärung zum Schutz der unbegleiteten minderjährigen Asylsuchenden (MNA)\n* Niederschwellige Gratis-Deutschkurse: Informationen für freiwillige Kursleitende\n"
    t.string "pdf_file_name"
    t.string "pdf_content_type"
    t.integer "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.bigint "submitted_by_id"
    t.index ["deleted_at"], name: "index_group_assignments_on_deleted_at"
    t.index ["group_offer_id"], name: "index_group_assignments_on_group_offer_id"
    t.index ["period_end"], name: "index_group_assignments_on_period_end"
    t.index ["period_end_set_by_id"], name: "index_group_assignments_on_period_end_set_by_id"
    t.index ["period_start"], name: "index_group_assignments_on_period_start"
    t.index ["submitted_at"], name: "index_group_assignments_on_submitted_at"
    t.index ["submitted_by_id"], name: "index_group_assignments_on_submitted_by_id"
    t.index ["termination_submitted_at"], name: "index_group_assignments_on_termination_submitted_at"
    t.index ["termination_submitted_by_id"], name: "index_group_assignments_on_termination_submitted_by_id"
    t.index ["termination_verified_at"], name: "index_group_assignments_on_termination_verified_at"
    t.index ["termination_verified_by_id"], name: "index_group_assignments_on_termination_verified_by_id"
    t.index ["volunteer_id"], name: "index_group_assignments_on_volunteer_id"
  end

  create_table "group_offer_categories", force: :cascade do |t|
    t.string "category_name"
    t.string "category_state", default: "active"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["deleted_at"], name: "index_group_offer_categories_on_deleted_at"
  end

  create_table "group_offer_categories_volunteers", id: false, force: :cascade do |t|
    t.bigint "group_offer_category_id", null: false
    t.bigint "volunteer_id", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_group_offer_categories_volunteers_on_deleted_at"
    t.index ["group_offer_category_id", "volunteer_id"], name: "index_group_offer_on_volunteer"
  end

  create_table "group_offers", force: :cascade do |t|
    t.string "title"
    t.string "offer_type", default: "internal_offer", null: false
    t.string "offer_state"
    t.integer "necessary_volunteers"
    t.text "description"
    t.boolean "women", default: false
    t.boolean "men", default: false
    t.boolean "children", default: false
    t.boolean "teenagers", default: false
    t.boolean "unaccompanied", default: false
    t.boolean "all", default: false
    t.boolean "long_term", default: false
    t.boolean "regular", default: false
    t.boolean "short_term", default: false
    t.boolean "workday", default: false
    t.boolean "weekend", default: false
    t.boolean "flexible", default: false
    t.boolean "morning", default: false
    t.boolean "afternoon", default: false
    t.boolean "evening", default: false
    t.text "schedule_details"
    t.datetime "deleted_at"
    t.string "organization"
    t.string "location"
    t.bigint "department_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "group_offer_category_id", null: false
    t.boolean "active", default: true
    t.bigint "creator_id"
    t.string "search_volunteer"
    t.bigint "period_end_set_by_id"
    t.date "period_start"
    t.date "period_end"
    t.text "comments"
    t.index ["creator_id"], name: "index_group_offers_on_creator_id"
    t.index ["deleted_at"], name: "index_group_offers_on_deleted_at"
    t.index ["department_id"], name: "index_group_offers_on_department_id"
    t.index ["group_offer_category_id"], name: "index_group_offers_on_group_offer_category_id"
    t.index ["period_end"], name: "index_group_offers_on_period_end"
    t.index ["period_end_set_by_id"], name: "index_group_offers_on_period_end_set_by_id"
    t.index ["period_start"], name: "index_group_offers_on_period_start"
    t.index ["search_volunteer"], name: "index_group_offers_on_search_volunteer"
  end

  create_table "hours", force: :cascade do |t|
    t.date "meeting_date"
    t.float "hours", default: 0.0
    t.string "activity"
    t.text "comments"
    t.bigint "volunteer_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "billing_expense_id"
    t.string "hourable_type"
    t.bigint "hourable_id"
    t.bigint "reviewer_id"
    t.index ["billing_expense_id"], name: "index_hours_on_billing_expense_id"
    t.index ["deleted_at"], name: "index_hours_on_deleted_at"
    t.index ["hourable_type", "hourable_id"], name: "index_hours_on_hourable_type_and_hourable_id"
    t.index ["meeting_date"], name: "index_hours_on_meeting_date"
    t.index ["reviewer_id"], name: "index_hours_on_reviewer_id"
    t.index ["volunteer_id"], name: "index_hours_on_volunteer_id"
  end

  create_table "imports", force: :cascade do |t|
    t.bigint "access_id"
    t.jsonb "store"
    t.string "importable_type"
    t.bigint "importable_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "base_origin_entity"
    t.index ["access_id"], name: "index_imports_on_access_id"
    t.index ["deleted_at"], name: "index_imports_on_deleted_at"
    t.index ["importable_type", "importable_id"], name: "index_imports_on_importable_type_and_importable_id"
  end

  create_table "journals", force: :cascade do |t|
    t.bigint "user_id"
    t.text "body"
    t.string "journalable_type"
    t.bigint "journalable_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
    t.bigint "assignment_id"
    t.string "title"
    t.index ["assignment_id"], name: "index_journals_on_assignment_id"
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

  create_table "performance_reports", force: :cascade do |t|
    t.date "period_start"
    t.date "period_end"
    t.integer "year"
    t.bigint "user_id"
    t.jsonb "report_content"
    t.string "title"
    t.text "comment"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_performance_reports_on_deleted_at"
    t.index ["user_id"], name: "index_performance_reports_on_user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id"
    t.string "profession"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "deleted_at"
    t.boolean "flexible", default: false
    t.boolean "morning", default: false
    t.boolean "afternoon", default: false
    t.boolean "evening", default: false
    t.boolean "workday", default: false
    t.boolean "weekend", default: false
    t.text "detailed_description"
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

  create_table "reminder_mailing_volunteers", force: :cascade do |t|
    t.bigint "volunteer_id"
    t.bigint "reminder_mailing_id"
    t.string "reminder_mailable_type"
    t.bigint "reminder_mailable_id"
    t.boolean "confirmed_form", default: false
    t.boolean "email_sent", default: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "picked", default: false
    t.datetime "process_submitted_at"
    t.bigint "process_submitted_by_id"
    t.index ["deleted_at"], name: "index_reminder_mailing_volunteers_on_deleted_at"
    t.index ["process_submitted_by_id"], name: "index_reminder_mailing_volunteers_on_process_submitted_by_id"
    t.index ["reminder_mailable_type", "reminder_mailable_id"], name: "reminder_mailable_index"
    t.index ["reminder_mailing_id"], name: "index_reminder_mailing_volunteers_on_reminder_mailing_id"
    t.index ["volunteer_id"], name: "index_reminder_mailing_volunteers_on_volunteer_id"
  end

  create_table "reminder_mailings", force: :cascade do |t|
    t.bigint "creator_id"
    t.text "body"
    t.string "subject"
    t.integer "kind", default: 0
    t.boolean "sending_triggered", default: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "obsolete", default: false
    t.index ["creator_id"], name: "index_reminder_mailings_on_creator_id"
    t.index ["deleted_at"], name: "index_reminder_mailings_on_deleted_at"
  end

  create_table "semester_processes", force: :cascade do |t|
    t.bigint "creator_id"
    t.datetime "period_start"
    t.datetime "period_end"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_semester_processes_on_creator_id"
    t.index ["deleted_at"], name: "index_semester_processes_on_deleted_at"
  end

  create_table "trial_feedbacks", force: :cascade do |t|
    t.text "body"
    t.integer "trial_feedbackable_id"
    t.string "trial_feedbackable_type"
    t.bigint "volunteer_id"
    t.bigint "author_id"
    t.bigint "reviewer_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_trial_feedbacks_on_author_id"
    t.index ["deleted_at"], name: "index_trial_feedbacks_on_deleted_at"
    t.index ["reviewer_id"], name: "index_trial_feedbacks_on_reviewer_id"
    t.index ["trial_feedbackable_id", "trial_feedbackable_type"], name: "trial_feedback_polymorphic_index"
    t.index ["volunteer_id"], name: "index_trial_feedbacks_on_volunteer_id"
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
    t.boolean "active"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email", "active"], name: "index_users_on_email_and_active", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "volunteers", force: :cascade do |t|
    t.date "birth_year"
    t.string "salutation"
    t.string "nationality"
    t.string "additional_nationality"
    t.string "profession"
    t.text "education"
    t.text "motivation"
    t.boolean "experience", default: false
    t.text "expectations"
    t.text "strengths"
    t.text "interests"
    t.string "state", default: "registered"
    t.boolean "man", default: false
    t.boolean "woman", default: false
    t.boolean "family", default: false
    t.boolean "kid", default: false
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
    t.integer "working_percent"
    t.text "volunteer_experience_desc"
    t.bigint "registrar_id"
    t.boolean "trial_period", default: false
    t.boolean "intro_course", default: false
    t.boolean "doc_sent", default: false
    t.boolean "bank_account", default: false
    t.boolean "evaluation", default: false
    t.boolean "unaccompanied", default: false
    t.text "other_offer_desc"
    t.text "own_kids"
    t.boolean "flexible", default: false
    t.boolean "morning", default: false
    t.boolean "afternoon", default: false
    t.boolean "evening", default: false
    t.boolean "workday", default: false
    t.boolean "weekend", default: false
    t.text "detailed_description"
    t.string "bank"
    t.string "iban"
    t.boolean "waive", default: false
    t.boolean "external", default: false
    t.integer "acceptance", default: 0
    t.datetime "accepted_at"
    t.datetime "rejected_at"
    t.datetime "resigned_at"
    t.datetime "undecided_at"
    t.boolean "take_more_assignments", default: false
    t.boolean "active", default: false
    t.date "activeness_might_end"
    t.datetime "invited_at"
    t.text "comments"
    t.text "additional_comments"
    t.boolean "teenager"
    t.bigint "department_id"
    t.datetime "last_billing_expense_on"
    t.index ["acceptance"], name: "index_volunteers_on_acceptance"
    t.index ["accepted_at"], name: "index_volunteers_on_accepted_at"
    t.index ["active"], name: "index_volunteers_on_active"
    t.index ["activeness_might_end"], name: "index_volunteers_on_activeness_might_end"
    t.index ["birth_year"], name: "index_volunteers_on_birth_year"
    t.index ["deleted_at"], name: "index_volunteers_on_deleted_at"
    t.index ["department_id"], name: "index_volunteers_on_department_id"
    t.index ["external"], name: "index_volunteers_on_external"
    t.index ["invited_at"], name: "index_volunteers_on_invited_at"
    t.index ["nationality"], name: "index_volunteers_on_nationality"
    t.index ["rejected_at"], name: "index_volunteers_on_rejected_at"
    t.index ["resigned_at"], name: "index_volunteers_on_resigned_at"
    t.index ["salutation"], name: "index_volunteers_on_salutation"
    t.index ["undecided_at"], name: "index_volunteers_on_undecided_at"
    t.index ["user_id"], name: "index_volunteers_on_user_id"
  end

  add_foreign_key "assignment_logs", "assignments"
  add_foreign_key "assignment_logs", "clients"
  add_foreign_key "assignment_logs", "volunteers"
  add_foreign_key "assignments", "clients"
  add_foreign_key "assignments", "users", column: "creator_id"
  add_foreign_key "assignments", "volunteers"
  add_foreign_key "certificates", "users"
  add_foreign_key "certificates", "volunteers"
  add_foreign_key "client_notifications", "users"
  add_foreign_key "clients", "users"
  add_foreign_key "events", "departments"
  add_foreign_key "feedbacks", "users", column: "author_id"
  add_foreign_key "group_offers", "departments"
  add_foreign_key "group_offers", "group_offer_categories"
  add_foreign_key "hours", "billing_expenses"
  add_foreign_key "journals", "assignments"
  add_foreign_key "journals", "users"
  add_foreign_key "performance_reports", "users"
  add_foreign_key "profiles", "users"
  add_foreign_key "trial_feedbacks", "users", column: "author_id"
  add_foreign_key "volunteers", "departments"
  add_foreign_key "volunteers", "users"
end
