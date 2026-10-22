class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.string :title, null: false
      t.text :description
      t.timestamps
    end

    create_table :ingredient_sections do |t|
      t.references :recipe, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, null: false
      t.timestamps
    end

    create_table :recipe_ingredients do |t|
      t.references :ingredient_section, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :quantity
      t.string :unit
      t.integer :position, null: false
      t.timestamps
    end

    create_table :recipe_steps do |t|
      t.references :recipe, null: false, foreign_key: true
      t.text :instruction, null: false
      t.integer :position, null: false
      t.timestamps
    end

    { recipes: :title, ingredient_sections: :name, recipe_ingredients: :name, recipe_steps: :instruction }.each do |table, column|
      add_check_constraint table, "#{column} ~ '[^[:space:]]'", name: "#{table}_#{column}_present"
    end

    { ingredient_sections: :recipe_id, recipe_ingredients: :ingredient_section_id, recipe_steps: :recipe_id }.each do |table, parent|
      add_index table, [ parent, :position ], unique: true
      add_check_constraint table, "position >= 0", name: "#{table}_position_nonnegative"
    end
    add_check_constraint :recipe_ingredients, "quantity > 0 AND quantity < 'Infinity'::numeric", name: "recipe_ingredients_quantity_positive"
  end
end
