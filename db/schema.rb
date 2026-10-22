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

ActiveRecord::Schema[8.1].define(version: 2026_10_22_110000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "ingredient_sections", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.string "name", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id", "position"], name: "index_ingredient_sections_on_recipe_id_and_position", unique: true
    t.index ["recipe_id"], name: "index_ingredient_sections_on_recipe_id"
    t.check_constraint "\"position\" >= 0", name: "ingredient_sections_position_nonnegative"
    t.check_constraint "name::text ~ '[^[:space:]]'::text", name: "ingredient_sections_name_present"
  end

  create_table "recipe_ingredients", force: :cascade do |t|
    t.bigint "ingredient_section_id", null: false
    t.string "name", null: false
    t.decimal "quantity"
    t.string "unit"
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_section_id", "position"], name: "index_recipe_ingredients_on_ingredient_section_id_and_position", unique: true
    t.index ["ingredient_section_id"], name: "index_recipe_ingredients_on_ingredient_section_id"
    t.check_constraint "\"position\" >= 0", name: "recipe_ingredients_position_nonnegative"
    t.check_constraint "name::text ~ '[^[:space:]]'::text", name: "recipe_ingredients_name_present"
    t.check_constraint "quantity > 0::numeric AND quantity < 'Infinity'::numeric", name: "recipe_ingredients_quantity_positive"
  end

  create_table "recipe_steps", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.text "instruction", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id", "position"], name: "index_recipe_steps_on_recipe_id_and_position", unique: true
    t.index ["recipe_id"], name: "index_recipe_steps_on_recipe_id"
    t.check_constraint "\"position\" >= 0", name: "recipe_steps_position_nonnegative"
    t.check_constraint "instruction ~ '[^[:space:]]'::text", name: "recipe_steps_instruction_present"
  end

  create_table "recipes", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "title::text ~ '[^[:space:]]'::text", name: "recipes_title_present"
  end

  add_foreign_key "ingredient_sections", "recipes"
  add_foreign_key "recipe_ingredients", "ingredient_sections"
  add_foreign_key "recipe_steps", "recipes"
end
