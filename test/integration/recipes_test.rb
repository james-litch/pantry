require "test_helper"
require_relative "../support/recipe_test_data"

class RecipesTest < ActionDispatch::IntegrationTest
  include RecipeTestData

  test "AC7 homepage empty state and newest first recipe links" do
    get root_path
    assert_response :success
    assert_select "h2", "Your first recipe starts here"
    assert_select "a[href=?]", new_recipe_path, text: "New recipe"

    older = Recipe.create!(recipe_attributes.merge(title: "Older recipe", created_at: 1.day.ago))
    newer = Recipe.create!(recipe_attributes.merge(title: "Newer recipe"))
    get root_path
    assert_equal [ newer.title, older.title ], css_select("main ul li h2").map(&:text)
    assert_select "a[href=?]", recipe_path(newer)
    assert_select "a[href=?]", recipe_path(older)
  end

  test "AC1 AC2 AC8 AC9 create redirects to complete reloadable detail with exact amounts" do
    assert_difference({ "Recipe.count" => 1, "IngredientSection.count" => 2, "RecipeIngredient.count" => 5, "RecipeStep.count" => 2 }) do
      post recipes_path, params: { recipe: recipe_attributes }
    end
    recipe = Recipe.order(:id).last
    assert_redirected_to recipe_path(recipe)
    assert_response :see_other
    follow_redirect!
    assert_select "[role=status]", "Recipe saved. Ready when you are."
    2.times do
      get recipe_path(recipe)
      assert_response :success
      assert_select "h1", recipe.title
      assert_equal [ "For the potatoes", "For the dressing" ], css_select("h3").map(&:text)
      assert_equal [ "Roast the potatoes.", "Add the dressing." ], css_select("ol li").map { |li| li.text.strip }
      assert_select "li", text: /Olive oil\s+0.5 tbsp/
      assert_select "li", text: /Potatoes\s+2/
      assert_select "li", text: /Lemon juice\s+to taste/
      assert_select "li", text: "Salt"
      assert_select "li", text: "Pepper"
    end
    get recipe_path(id: -1)
    assert_response :not_found
  end

  test "AC4 invalid later rows retain all input and can be corrected" do
    attributes = recipe_attributes
    attributes[:ingredient_sections_attributes].last[:recipe_ingredients_attributes].last[:quantity] = "1/2"
    attributes[:recipe_steps_attributes].last[:instruction] = "  "
    assert_no_changes -> { recipe_record_counts } do
      post recipes_path, params: { recipe: attributes }
    end
    assert_response :unprocessable_content
    assert_select "input[value=?]", attributes[:title]
    assert_select "textarea", text: attributes[:description]
    assert_select "input[value='1/2'][aria-invalid=true]"
    assert_select "input[value='to taste']"
    assert_select "p", text: "Quantity must be a positive decimal, such as 0.5"
    assert_select "p", text: "Instruction can't be blank"
    assert_equal 7, css_select("input[name$='[name]']").reject { |input| input.ancestors("template").any? }.size
    attributes[:ingredient_sections_attributes].last[:recipe_ingredients_attributes].last[:quantity] = "0.5"
    attributes[:recipe_steps_attributes].last[:instruction] = "Serve."
    post recipes_path, params: { recipe: attributes }
    assert_response :see_other
  end

  test "AC4 missing collections remain empty with actionable errors" do
    post recipes_path, params: { recipe: { title: "Soup" } }
    assert_response :unprocessable_content
    assert_select "p", text: "Ingredient sections must include at least one section"
    assert_select "p", text: "Recipe steps must include at least one step"
    assert_select "button", text: "Add section"
    assert_select "button", text: "Add step"
  end

  test "AC5 all recipe text is escaped on detail and list" do
    script = '<script>alert("recipe")</script>'
    attributes = {
      title: script, description: script,
      ingredient_sections_attributes: [ { name: script, recipe_ingredients_attributes: [ { name: script, unit: script } ] } ],
      recipe_steps_attributes: [ { instruction: script } ]
    }
    recipe = Recipe.create!(attributes)
    get recipe_path(recipe)
    assert_select "main script", count: 0
    assert_select "h1", text: script
    assert_select "article header p", text: script
    assert_select "h3", text: script
    assert_select "li span", text: script, count: 2
    assert_select "ol li", text: script
    get root_path
    assert_select "main script", count: 0
    assert_select "h2", text: script
  end

  test "client cannot choose record IDs or ordering positions" do
    attributes = recipe_attributes
    attributes[:id] = 123
    attributes[:ingredient_sections_attributes].first[:position] = 99
    post recipes_path, params: { recipe: attributes }
    recipe = Recipe.order(:id).last
    assert_equal 0, recipe.ingredient_sections.first.position
    assert_response :see_other
  end
end
