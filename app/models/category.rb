class Category < ApplicationRecord
  # Associations
  has_many :products, dependent: :restrict_with_error
  belongs_to :parent_category, class_name: "Category", optional: true
  has_many :subcategories, class_name: "Category",
           foreign_key: "parent_category_id", dependent: :destroy

  # Validations (Requirement 4.2.1)
  validates :name, presence: true, uniqueness: true,
            length: { minimum: 2, maximum: 100 }
  validates :description, length: { maximum: 1000 }, allow_blank: true

  # Prevent circular references
  validate :parent_cannot_be_self

  # Scopes
  scope :top_level, -> { where(parent_category_id: nil) }
  scope :with_products, -> { joins(:products).distinct }

  # Methods
  def product_count
    products.count
  end

  private

  def parent_cannot_be_self
    if parent_category_id.present? && id.present? && parent_category_id == id
      errors.add(:parent_category_id, "cannot be the category itself")
    end
  end

  # Ransack configuration for ActiveAdmin search
  def self.ransackable_associations(auth_object = nil)
    [ "parent_category", "products", "subcategories" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "description", "id", "name", "parent_category_id", "updated_at" ]
  end
end
