require "test_helper"
require_relative "../support/recipe_test_data"

class RecipeTest < ActiveSupport::TestCase
  include RecipeTestData

  test "AC1 AC2 AC9 saves the complete ordered graph and decimal or absent amounts" do
    recipe = Recipe.create!(recipe_attributes).reload
    assert_equal [ "For the potatoes", "For the dressing" ], recipe.ingredient_sections.map(&:name)
    assert_equal [ 0, 1 ], recipe.ingredient_sections.map(&:position)
    assert_equal [ "Potatoes", "Salt" ], recipe.ingredient_sections.first.recipe_ingredients.map(&:name)
    dressing = recipe.ingredient_sections.last.recipe_ingredients
    assert_equal [ "Olive oil", "Lemon juice", "Pepper" ], dressing.map(&:name)
    assert_equal [ 0, 1, 2 ], dressing.map(&:position)
    assert_equal BigDecimal("0.5"), dressing.first.quantity
    assert_nil dressing.second.quantity
    assert_nil dressing.third.quantity
    assert_equal [ "Roast the potatoes.", "Add the dressing." ], recipe.recipe_steps.map(&:instruction)
    assert_equal [ 0, 1 ], recipe.recipe_steps.map(&:position)
  end

  test "AC4 every required field and structure rejects missing or whitespace values atomically" do
    mutations = [
      ->(a) { a[:title] = " \t\n" },
      ->(a) { a[:title] = nil },
      ->(a) { a[:ingredient_sections_attributes].last[:name] = " " },
      ->(a) { a[:ingredient_sections_attributes].last[:recipe_ingredients_attributes].last[:name] = " " },
      ->(a) { a[:ingredient_sections_attributes].last[:recipe_ingredients_attributes] = [] },
      ->(a) { a[:ingredient_sections_attributes] = [] },
      ->(a) { a[:recipe_steps_attributes].last[:instruction] = "\n " },
      ->(a) { a[:recipe_steps_attributes] = [] }
    ]
    mutations.each do |mutate|
      attributes = recipe_attributes
      mutate.call(attributes)
      recipe = Recipe.new(attributes)
      assert_no_changes -> { recipe_record_counts } do
        assert_not recipe.save
        assert recipe.errors.any?
      end
    end
  end

  test "AC9 rejects invalid quantities without losing the original input" do
    [ "0", "-1", "abc", "1/2", "NaN", "Infinity", "0.5tbsp" ].each do |quantity|
      recipe = Recipe.new(recipe_attributes)
      ingredient = recipe.ingredient_sections.last.recipe_ingredients.last
      ingredient.quantity = quantity
      assert_no_changes -> { recipe_record_counts } do
        assert_not recipe.save, "Expected #{quantity} to be invalid"
      end
      assert_equal quantity, ingredient.quantity_before_type_cast
      assert ingredient.errors[:quantity].any?
    end
  end

  test "AC4 AC9 blank optional values and duplicate titles and names are allowed" do
    2.times do
      attributes = recipe_attributes.merge(description: "")
      attributes[:ingredient_sections_attributes].last[:recipe_ingredients_attributes].last.merge!(name: "Salt", quantity: "  ")
      recipe = Recipe.create!(attributes)
      assert_nil recipe.reload.ingredient_sections.last.recipe_ingredients.last.quantity
    end
  end

  test "database enforces required text positive amounts positions and parent references" do
    recipe = Recipe.create!(recipe_attributes)
    ingredient = recipe.ingredient_sections.first.recipe_ingredients.first
    [ { name: " \t" }, { quantity: 0 }, { quantity: -1 }, { position: -1 }, { ingredient_section_id: -1 } ].each do |attributes|
      assert_raises ActiveRecord::StatementInvalid do
        RecipeIngredient.transaction(requires_new: true) { ingredient.update_columns(attributes) }
      end
    end
    assert_raises ActiveRecord::RecordNotUnique do
      RecipeIngredient.transaction(requires_new: true) do
        ingredient.reload.dup.save!(validate: false)
      end
    end
  end
end
