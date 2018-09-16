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

ActiveRecord::Schema.define(version: 20180915171430) do

  create_table "accounts", force: :cascade do |t|
    t.string   "user"
    t.string   "seller_id"
    t.string   "mws_auth_token"
    t.string   "mws_aws_key"
    t.string   "mws_secret_key"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "profit_rate"
    t.integer  "shipping"
    t.string   "sub_keyword"
    t.integer  "used_profit_rate"
  end

  create_table "products", force: :cascade do |t|
    t.string   "user"
    t.string   "asin"
    t.string   "condition"
    t.integer  "new_sale1"
    t.integer  "new_sale2"
    t.integer  "new_sale3"
    t.integer  "new_avg3"
    t.integer  "used_sale1"
    t.integer  "used_sale2"
    t.integer  "used_sale3"
    t.integer  "used_avg3"
    t.boolean  "check1"
    t.integer  "cart_price"
    t.integer  "cart_income"
    t.integer  "used_price"
    t.integer  "used_income"
    t.boolean  "check2"
    t.string   "title"
    t.string   "mpn"
    t.string   "item_image"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "new_bid_price"
    t.integer  "used_bid_price"
    t.integer  "new_negotiate_price"
    t.integer  "used_negotiate_price"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "admin_flg"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
