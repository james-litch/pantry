require "application_system_test_case"
require_relative "../support/recipe_test_data"

class RecipeFlowTest < ApplicationSystemTestCase
  include RecipeTestData

  test "AC1 AC2 AC3 AC6 AC7 creates an ordered recipe with nested additions and removals" do
    visit root_path
    click_on "New recipe"
    assert_selector "fieldset legend", text: "Section 1", count: 1
    assert_selector "fieldset legend", text: "Ingredient 1", count: 1
    assert_selector "fieldset legend", text: "Step 1", count: 1
    fill_in "Recipe title", with: "Lemon potatoes"
    fill_in "Description (optional)", with: "Sunday lunch"
    within section_row(0) do
      fill_in "Section name", with: "Potatoes"
      fill_in "Ingredient name", with: "Potatoes"
      fill_in "Quantity (optional)", with: "2"
      click_on "Add ingredient"
      assert_focused "input[name$='[name]']", value: ""
      within(ingredient_row(1)) { fill_in "Ingredient name", with: "Salt" }
      assert_field "Ingredient name", with: "Salt"
      click_on "Add ingredient"
      within ingredient_row(2) do
        fill_in "Ingredient name", with: "Discard me"
        click_on "Remove ingredient"
      end
      assert_focused "input[name$='[name]']", value: "Salt"
    end
    click_on "Add section"
    assert_focused "input[name$='[name]']", value: ""
    within section_row(1) do
      fill_in "Section name", with: "Discarded section"
      fill_in "Ingredient name", with: "Discarded ingredient"
      click_on "Add ingredient"
      click_on "Remove section"
    end
    assert_focused "input[name$='[name]']", value: "Potatoes"
    click_on "Add section"
    within section_row(1) do
      fill_in "Section name", with: "Dressing"
      fill_in "Ingredient name", with: "Olive oil"
      fill_in "Quantity (optional)", with: "0.5"
      fill_in "Unit (optional)", with: "tbsp"
      click_on "Add ingredient"
      within(ingredient_row(1)) { fill_in "Ingredient name", with: "Pepper" }
    end
    fill_in "Instruction", with: "Roast."
    click_on "Add step"
    assert_focused "textarea", value: ""
    within(step_row(1)) { fill_in "Instruction", with: "Discard this step" }
    click_on "Add step"
    within(step_row(2)) { fill_in "Instruction", with: "Dress and serve." }
    within(step_row(1)) { click_on "Remove step" }
    assert_focused "textarea", value: "Dress and serve."
    click_on "Save recipe"
    assert_text "Recipe saved. Ready when you are."
    assert_selector "h1", text: "Lemon potatoes"
    assert_equal [ "Roast.", "Dress and serve." ], all("ol li").map(&:text)
    assert_no_text "Discard"
    recipe = Recipe.order(:id).last.reload
    assert_equal [ "Potatoes", "Dressing" ], recipe.ingredient_sections.map(&:name)
    assert_equal [ "Potatoes", "Salt" ], recipe.ingredient_sections.first.recipe_ingredients.map(&:name)
    assert_equal [ "Olive oil", "Pepper" ], recipe.ingredient_sections.last.recipe_ingredients.map(&:name)
    click_on "← All recipes"
    click_on "Lemon potatoes"
    assert_selector "h1", text: "Lemon potatoes"
    page.refresh
    assert_text "0.5 tbsp"
  end

  test "AC4 AC6 AC9 invalid later rows retain input and keyboard correction saves the full recipe" do
    visit new_recipe_path
    fill_in "Recipe title", with: "Soup"
    fill_in "Description (optional)", with: "Keep this description"
    within section_row(0) do
      fill_in "Section name", with: "Soup"
      fill_in "Ingredient name", with: "Water"
      fill_in "Quantity (optional)", with: "2"
      fill_in "Unit (optional)", with: "cups"
    end
    click_on "Add section"
    within section_row(1) do
      fill_in "Section name", with: "Seasoning"
      fill_in "Ingredient name", with: "Salt"
      fill_in "Quantity (optional)", with: "1/2"
      fill_in "Unit (optional)", with: "tsp"
    end
    fill_in "Instruction", with: "Simmer."
    click_on "Add step"
    assert_no_changes -> { recipe_record_counts } do
      click_on "Save recipe"
      assert_selector "[role=alert]:focus"
    end
    assert_field "Recipe title", with: "Soup"
    assert_field "Description (optional)", with: "Keep this description"
    within section_row(1) do
      assert_text "Section 2"
      assert_field "Quantity (optional)", with: "1/2"
      assert_text "Quantity must be a positive decimal, such as 0.5"
      fill_in "Quantity (optional)", with: "0.5"
      find_field("Quantity (optional)").send_keys(:tab)
      assert_focused "input[name$='[unit]']", value: "tsp"
    end
    within step_row(1) do
      assert_text "Step 2"
      assert_text "Instruction can't be blank"
      fill_in "Instruction", with: "Season and serve."
    end
    click_on "Save recipe"
    assert_text "Recipe saved. Ready when you are."
    assert_text "Keep this description"
    assert_text "0.5 tsp"
    assert_text "Season and serve."
    assert_equal [ 1, 2, 2, 2 ], recipe_record_counts
  end

  test "AC3 AC4 removing final rows validates and allows restoring the missing structure" do
    visit new_recipe_path
    fill_in "Recipe title", with: "A pinch of salt"
    fill_in "Section name", with: "Seasoning"
    click_on "Remove ingredient"
    assert_selector "button:focus", text: "Add ingredient"
    click_on "Remove step"
    assert_selector "button:focus", text: "Add step"
    click_on "Save recipe"
    assert_text "Recipe ingredients must include at least one ingredient"
    assert_text "Recipe steps must include at least one step"
    click_on "Remove section"
    assert_selector "button:focus", text: "Add section"
    click_on "Save recipe"
    assert_text "Ingredient sections must include at least one section"
    click_on "Add section"
    fill_in "Section name", with: "Seasoning"
    fill_in "Ingredient name", with: "Salt"
    click_on "Add step"
    fill_in "Instruction", with: "Season to taste."
    click_on "Save recipe"
    assert_text "Recipe saved. Ready when you are."
    assert_selector "li", text: "Salt", exact_text: true
  end

  test "AC6 responsive empty populated form error and detail states with long content" do
    [ [ 390, 844 ], [ 1400, 1000 ] ].each do |width, height|
      page.current_window.resize_to(width, height)
      # Chrome's desktop window has a minimum width; override the content viewport
      # so the mobile check really runs at 390px, including in headless CI.
      page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride", width: width, height: height, deviceScaleFactor: 1, mobile: false)
      visit root_path
      assert_equal width, page.evaluate_script("window.innerWidth")
      inspect_layout("#{width}-empty")
      click_on "New recipe"
      inspect_layout("#{width}-new")
      fill_in "Recipe title", with: "Slow-roasted vegetables with a lemon and herb dressing for a long Sunday lunch"
      fill_in "Description (optional)", with: "A recipe to share. " * 20
      fill_in "Section name", with: "For the vegetables and their deliciously fragrant dressing"
      fill_in "Ingredient name", with: "An exceptionally long ingredient name " * 4
      fill_in "Quantity (optional)", with: "abc"
      fill_in "Instruction", with: "Roast until golden, turning occasionally. " * 10
      click_on "Add ingredient"
      within(ingredient_row(1)) { fill_in "Ingredient name", with: "Pepper" }
      click_on "Save recipe"
      assert_selector "[role=alert]"
      inspect_layout("#{width}-error")
      within(ingredient_row(0)) { fill_in "Quantity (optional)", with: "0.5" }
      click_on "Save recipe"
      assert_text "Recipe saved. Ready when you are."
      inspect_layout("#{width}-detail")
      click_on "← All recipes"
      inspect_layout("#{width}-populated")
      Recipe.destroy_all
    end
  ensure
    page.driver.browser.execute_cdp("Emulation.clearDeviceMetricsOverride")
  end

  private

  def section_row(index)
    all("#sections-heading ~ [data-nested-fields-target=list] > fieldset")[index]
  end

  def ingredient_row(index)
    all('[data-nested-fields-label-value="Ingredient"] > [data-nested-fields-target="list"] > fieldset')[index]
  end

  def step_row(index)
    all("#steps-heading ~ [data-nested-fields-target=list] > fieldset")[index]
  end

  def assert_focused(selector, value:)
    assert_selector "#{selector}:focus"
    assert_equal value, find("#{selector}:focus").value
  end

  def inspect_layout(name)
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth"), "Horizontal overflow: #{name}"
    if name.end_with?("-new", "-error")
      all("input:not([type=hidden]):not([type=submit]), textarea").each do |input|
        assert_selector "label[for='#{input[:id]}']"
      end
    end
    if ENV["VISUAL_REVIEW"]
      dimensions = page.driver.browser.execute_cdp("Page.getLayoutMetrics").fetch("cssContentSize")
      capture = page.driver.browser.execute_cdp("Page.captureScreenshot", captureBeyondViewport: true,
        clip: dimensions.merge("scale" => 1))
      File.binwrite(Rails.root.join("tmp/screenshots/recipes-#{name}.png"), Base64.decode64(capture.fetch("data")))
    end
  end
end
