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

ActiveRecord::Schema[7.2].define(version: 2024_11_26_093350) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "expenses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "simulation_id", null: false
    t.decimal "housing_expense", default: "0.0", null: false
    t.date "repayment_date", default: -> { "CURRENT_DATE" }, null: false
    t.decimal "living_expenses", default: "0.0", null: false
    t.decimal "monthly_premiums", default: "0.0", null: false
    t.decimal "other_expenses", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "housing_expense >= 0::numeric", name: "check_housing_expense_positive"
    t.check_constraint "living_expenses >= 0::numeric", name: "check_living_expenses_positive"
    t.check_constraint "monthly_premiums >= 0::numeric", name: "check_monthly_premiums_positive"
    t.check_constraint "other_expenses >= 0::numeric", name: "check_other_expenses_positive"
  end

  create_table "incomes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "simulation_id", null: false
    t.string "person_type", null: false
    t.decimal "income", default: "0.0", null: false
    t.date "retirement_date", null: false
    t.decimal "retirement_pay", default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["simulation_id"], name: "index_incomes_on_simulation_id"
    t.index ["user_id"], name: "index_incomes_on_user_id"
    t.check_constraint "income >= 0::numeric", name: "income_positive_check"
    t.check_constraint "retirement_pay >= 0::numeric", name: "retirement_pay_positive_check"
  end

  create_table "scenarios", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "simulation_id", null: false
    t.string "scenario_type"
    t.jsonb "asset_scenario", default: {}
    t.jsonb "balance_scenario", default: {}
    t.decimal "total_income"
    t.decimal "total_expense"
    t.decimal "total_balance"
    t.decimal "withdrawal"
    t.decimal "shortage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["simulation_id"], name: "index_scenarios_on_simulation_id"
    t.index ["user_id"], name: "index_scenarios_on_user_id"
  end

  create_table "simulations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "inflation_rate"
    t.jsonb "income_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "expense_data"
    t.jsonb "asset_data"
    t.jsonb "lifeevent_data"
    t.index ["user_id"], name: "index_simulations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.date "date_of_birth", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "incomes", "simulations"
  add_foreign_key "incomes", "users"
  add_foreign_key "scenarios", "simulations"
  add_foreign_key "scenarios", "users"
  add_foreign_key "simulations", "users"
end
