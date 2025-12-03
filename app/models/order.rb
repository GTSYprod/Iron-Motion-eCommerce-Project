class Order < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :address
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  # Nested attributes for order items (Required for checkout)
  accepts_nested_attributes_for :order_items

  # Constants
  ORDER_STATUSES = %w[pending processing shipped delivered cancelled].freeze

  # Validations (Requirement 4.2.1)
  validates :user, presence: true
  validates :address, presence: true
  validates :order_status, presence: true,
            inclusion: { in: ORDER_STATUSES }
  validates :order_total, presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :calculate_order_total, if: :new_record?
  after_create :update_product_stock

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(order_status: status) if status.present? }
  scope :pending, -> { where(order_status: "pending") }
  scope :processing, -> { where(order_status: "processing") }
  scope :shipped, -> { where(order_status: "shipped") }
  scope :delivered, -> { where(order_status: "delivered") }
  scope :cancelled, -> { where(order_status: "cancelled") }

  # Helper methods for status checks
  def pending?
    order_status == "pending"
  end

  def processing?
    order_status == "processing"
  end

  def shipped?
    order_status == "shipped"
  end

  def delivered?
    order_status == "delivered"
  end

  def cancelled?
    order_status == "cancelled"
  end

  # Ransack configuration for ActiveAdmin search
  def self.ransackable_associations(auth_object = nil)
    [ "address", "order_items", "products", "user" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "address_id", "created_at", "id", "order_status", "order_total", "updated_at", "user_id" ]
  end

  private

  def calculate_order_total
    self.order_total = order_items.sum { |item| item.price_at_purchase * item.quantity }
  end

  def update_product_stock
    order_items.each do |item|
      product = item.product
      product.update(stock_quantity: product.stock_quantity - item.quantity)
    end
  end
end
