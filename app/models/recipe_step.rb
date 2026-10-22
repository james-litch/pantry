class RecipeStep < ApplicationRecord
  belongs_to :recipe, inverse_of: :recipe_steps
  validates :instruction, presence: true
end
