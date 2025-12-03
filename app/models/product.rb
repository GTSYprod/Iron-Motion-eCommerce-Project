class Product < ApplicationRecord
  # Active Storage attachments (Requirement 1.3)
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 200, 200 ]
    attachable.variant :medium, resize_to_limit: [ 500, 500 ]
    attachable.variant :large, resize_to_limit: [ 1000, 1000 ]
  end

  # Associations
  belongs_to :category
  has_many :order_items, dependent: :restrict_with_error
  has_many :shopping_cart_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_many :shopping_carts, through: :shopping_cart_items

  # Constants
  STOCK_STATUSES = %w[in_stock out_of_stock low_stock].freeze

  # Validations (Requirement 4.2.1)
  validates :name, presence: true, length: { minimum: 3, maximum: 200 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :price, presence: true,
            numericality: { greater_than: 0, less_than: 1_000_000 }
  validates :category, presence: true
  validates :stock_status, presence: true,
            inclusion: { in: STOCK_STATUSES }
  validates :stock_quantity, numericality: {
    greater_than_or_equal_to: 0,
    only_integer: true
  }

  # Scopes for filtering (Requirement 2.4)
  scope :on_sale, -> { where(on_sale: true) }
  scope :new_arrivals, -> { where(is_new: true) }
  scope :recently_updated, -> { where("updated_at > ?", 7.days.ago).order(updated_at: :desc) }
  scope :in_stock, -> { where(stock_status: "in_stock") }
  scope :by_category, ->(category_id) { where(category_id: category_id) if category_id.present? }

  # Search (Requirement 2.6)
  scope :search, ->(query) {
    where("name ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%") if query.present?
  }

  # Pagination configuration (Requirement 2.5)
  paginates_per 12

  # Methods
  def primary_image
    images.first
  end

  def in_stock?
    stock_status == "in_stock" && stock_quantity > 0
  end

  def low_stock?
    stock_status == "low_stock"
  end

  def out_of_stock?
    stock_status == "out_of_stock" || stock_quantity == 0
  end

  # Ransack configuration for ActiveAdmin search
  def self.ransackable_associations(auth_object = nil)
    [ "category", "order_items", "orders", "shopping_cart_items", "shopping_carts" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "category_id", "created_at", "description", "id", "is_new", "name", "on_sale", "price", "specification", "stock_quantity", "stock_status", "updated_at" ]
  end
end
