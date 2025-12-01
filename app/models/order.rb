class Order < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :address
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  # Validations (Requirement 4.2.1)
  validates :user, presence: true
  validates :address, presence: true
  validates :order_status, presence: true,
            inclusion: { in: %w[pending processing shipped delivered cancelled] }
  validates :order_total, presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :calculate_order_total, if: :new_record?
  after_create :update_product_stock

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(order_status: status) if status.present? }

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
