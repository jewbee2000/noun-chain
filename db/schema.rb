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

ActiveRecord::Schema[7.1].define(version: 2024_04_03_204743) do
  create_table "games", force: :cascade do |t|
    t.integer "game_number"
    t.datetime "date", precision: nil
    t.string "start_word"
    t.string "end_word"
    t.integer "shortest_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "solutions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "game_id"
    t.datetime "timestamp", precision: nil
    t.string "chain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "uuid"
    t.integer "won"
    t.integer "current_streak"
    t.integer "max_streak"
    t.integer "plus_1"
    t.integer "plus_2"
    t.integer "plus_3"
    t.integer "plus_4"
    t.integer "plus_5"
    t.integer "plus_more"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
