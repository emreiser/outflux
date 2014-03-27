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

ActiveRecord::Schema.define(version: 20140327165049) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "countries", force: true do |t|
    t.text     "name"
    t.text     "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "alias"
    t.boolean  "emergency"
    t.text     "url"
  end

  create_table "refugee_counts", force: true do |t|
    t.integer  "year"
    t.integer  "origin_id"
    t.integer  "destination_id"
    t.integer  "total"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "refugee_counts", ["origin_id"], name: "index_refugee_counts_on_origin_id", using: :btree

  create_table "stories", force: true do |t|
    t.text     "title"
    t.text     "url"
    t.text     "image"
    t.text     "summary"
    t.datetime "pub_date"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stories", ["country_id"], name: "index_stories_on_country_id", using: :btree

end
