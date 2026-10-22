class RecipesController < ApplicationController
  def index
    @recipes = Recipe.newest_first
  end

  def new
    @recipe = Recipe.new
    @recipe.ingredient_sections.build.recipe_ingredients.build
    @recipe.recipe_steps.build
  end

  def create
    @recipe = Recipe.new(recipe_params)
    if @recipe.save
      redirect_to @recipe, notice: "Recipe saved. Ready when you are.", status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @recipe = Recipe.includes(ingredient_sections: :recipe_ingredients).includes(:recipe_steps).find(params[:id])
  end

  private

  def recipe_params
    params.require(:recipe).permit(:title, :description,
      ingredient_sections_attributes: [ :name, recipe_ingredients_attributes: [ :name, :quantity, :unit ] ],
      recipe_steps_attributes: [ :instruction ])
  end
end
