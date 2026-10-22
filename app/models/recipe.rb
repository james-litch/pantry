class Recipe < ApplicationRecord
  has_many :ingredient_sections, -> { order(:position) }, inverse_of: :recipe, dependent: :destroy
  has_many :recipe_steps, -> { order(:position) }, inverse_of: :recipe, dependent: :destroy

  accepts_nested_attributes_for :ingredient_sections, :recipe_steps

  before_validation :assign_positions, on: :create
  validates :title, presence: true
  validates :ingredient_sections, length: { minimum: 1, message: "must include at least one section" }
  validates :recipe_steps, length: { minimum: 1, message: "must include at least one step" }

  scope :newest_first, -> { order(created_at: :desc, id: :desc) }

  private

  def assign_positions
    ingredient_sections.each_with_index { |section, index| section.position = index }
    recipe_steps.each_with_index { |step, index| step.position = index }
  end
end
