class RecipeIngredient < ApplicationRecord
  belongs_to :ingredient_section, inverse_of: :recipe_ingredients
  validates :name, presence: true
  validate :positive_decimal_quantity

  private

  def positive_decimal_quantity
    raw = quantity_before_type_cast
    if raw.blank?
      self.quantity = nil
    elsif !(raw.is_a?(Numeric) || raw.to_s.match?(/\A(?:\d+(?:\.\d+)?|\.\d+)\z/)) || quantity.nil? || !quantity.finite? || quantity <= 0
      errors.add(:quantity, "must be a positive decimal, such as 0.5")
    end
  end
end
