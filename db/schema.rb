# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160406121919) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "faults", force: :cascade do |t|
    t.string   "fault_type"
    t.string   "fault_description"
    t.string   "fault_reported_by"
    t.integer  "item_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "fault_status"
    t.datetime "resolved_at"
    t.string   "case_note"
  end

  add_index "faults", ["item_id"], name: "index_faults_on_item_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.string   "item_type"
    t.string   "item_identifier"
    t.string   "item_latitude"
    t.string   "item_longitude"
    t.string   "item_location"
    t.string   "item_repair_time"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_foreign_key "faults", "items"
end
