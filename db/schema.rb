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

ActiveRecord::Schema.define(version: 20180310221352) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "cik"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ticker_symbol"
    t.index ["cik"], name: "index_companies_on_cik"
    t.index ["name"], name: "index_companies_on_name"
    t.index ["ticker_symbol"], name: "index_companies_on_ticker_symbol"
  end

  create_table "forms", force: :cascade do |t|
    t.string "name"
    t.date "filing_date"
    t.string "filing_url"
    t.integer "company_id"
    t.integer "quarter"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "filing_raw_text"
    t.index ["company_id"], name: "index_forms_on_company_id"
    t.index ["filing_date"], name: "index_forms_on_filing_date"
    t.index ["filing_url"], name: "index_forms_on_filing_url"
    t.index ["name"], name: "index_forms_on_name"
    t.index ["quarter"], name: "index_forms_on_quarter"
    t.index ["year"], name: "index_forms_on_year"
  end

  create_table "stock_prices", force: :cascade do |t|
    t.float "open"
    t.float "high"
    t.float "low"
    t.float "close"
    t.date "date"
    t.string "symbol"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["close"], name: "index_stock_prices_on_close"
    t.index ["date"], name: "index_stock_prices_on_date"
    t.index ["high"], name: "index_stock_prices_on_high"
    t.index ["low"], name: "index_stock_prices_on_low"
    t.index ["open"], name: "index_stock_prices_on_open"
    t.index ["symbol"], name: "index_stock_prices_on_symbol"
  end

end
