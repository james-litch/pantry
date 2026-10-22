class IngredientSection < ApplicationRecord
  belongs_to :recipe, inverse_of: :ingredient_sections
  has_many :recipe_ingredients, -> { order(:position) }, inverse_of: :ingredient_section, dependent: :destroy
  accepts_nested_attributes_for :recipe_ingredients

  before_validation :assign_positions, on: :create
  validates :name, presence: true
  validates :recipe_ingredients, length: { minimum: 1, message: "must include at least one ingredient" }

  private

  def assign_positions
    recipe_ingredients.each_with_index { |ingredient, index| ingredient.position = index }
  end
end
