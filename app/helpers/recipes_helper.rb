module RecipesHelper
  def recipe_input_options(form, attribute)
    invalid = form.object.errors[attribute].any?
    {
      class: "mt-2 block w-full rounded-lg border border-line bg-white px-3 py-2.5 text-ink aria-invalid:border-danger",
      aria: { invalid: invalid, describedby: invalid ? form.field_id(attribute, :error) : nil }
    }
  end

  def ingredient_amount(ingredient)
    quantity = ingredient.quantity&.to_s("F")&.sub(/\.0+\z/, "")
    [ quantity, ingredient.unit.presence ].compact.join(" ")
  end
end
