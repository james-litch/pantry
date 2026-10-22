module RecipeTestData
  def recipe_attributes
    {
      title: "Lemon potatoes", description: "A favourite for Sunday lunch.",
      ingredient_sections_attributes: [
        { name: "For the potatoes", recipe_ingredients_attributes: [
          { name: "Potatoes", quantity: "2", unit: "" },
          { name: "Salt", quantity: "", unit: "" }
        ] },
        { name: "For the dressing", recipe_ingredients_attributes: [
          { name: "Olive oil", quantity: "0.5", unit: "tbsp" },
          { name: "Lemon juice", quantity: "", unit: "to taste" },
          { name: "Pepper", quantity: "", unit: "" }
        ] }
      ],
      recipe_steps_attributes: [ { instruction: "Roast the potatoes." }, { instruction: "Add the dressing." } ]
    }
  end

  def recipe_record_counts
    [ Recipe, IngredientSection, RecipeIngredient, RecipeStep ].map(&:count)
  end
end
