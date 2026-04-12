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

ActiveRecord::Schema[8.1].define(version: 2026_04_12_090128) do
  create_table "bookings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "booking_date", null: false
    t.datetime "created_at", null: false
    t.integer "end_slot", null: false
    t.text "notes"
    t.datetime "paid_at"
    t.datetime "payment_expires_at"
    t.string "purpose"
    t.bigint "resource_id", null: false
    t.integer "start_slot", null: false
    t.integer "status", default: 0, null: false
    t.string "stripe_session_id"
    t.decimal "total_cost", precision: 10, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["payment_expires_at"], name: "idx_bookings_pending_payment_expiry"
    t.index ["resource_id", "booking_date", "status"], name: "idx_bookings_availability"
    t.index ["resource_id"], name: "index_bookings_on_resource_id"
    t.index ["user_id", "booking_date"], name: "idx_bookings_user_date"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "departments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.boolean "is_active", default: true, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_departments_on_code", unique: true
  end

  create_table "resources", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "advance_booking_days", default: 14
    t.string "building"
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.bigint "department_id", null: false
    t.text "description"
    t.boolean "is_active", default: true, null: false
    t.string "location"
    t.integer "max_slots_per_booking"
    t.integer "min_slots_per_booking", default: 1
    t.string "name", null: false
    t.integer "operating_end_slot", default: 44
    t.integer "operating_start_slot", default: 16
    t.decimal "price_per_unit", precision: 10, scale: 2, default: "0.0"
    t.integer "quantity", default: 1
    t.boolean "requires_approval", default: false, null: false
    t.string "room_type"
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["building"], name: "index_resources_on_building"
    t.index ["department_id"], name: "index_resources_on_department_id"
    t.index ["room_type"], name: "index_resources_on_room_type"
    t.index ["type"], name: "index_resources_on_type"
  end

  create_table "settings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.string "value"
    t.string "value_type", default: "string"
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "department_id"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.string "student_id"
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["student_id"], name: "index_users_on_student_id", unique: true
  end

  add_foreign_key "bookings", "resources"
  add_foreign_key "bookings", "users"
  add_foreign_key "resources", "departments"
  add_foreign_key "users", "departments", on_delete: :nullify
end
