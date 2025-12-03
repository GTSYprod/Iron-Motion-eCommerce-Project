class OrderItem < ApplicationRecord
  # Associations
  belongs_to :order
  belongs_to :product

  # Validations (Requirement 4.2.1)
  validates :product, presence: true
  validates :order, presence: true
  validates :quantity, presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :price_at_purchase, presence: true,
            numericality: { greater_than: 0 }

  # Callbacks
  before_validation :set_price_at_purchase, on: :create

  # Methods
  def subtotal
    quantity * price_at_purchase
  end

  private

  def set_price_at_purchase
    self.price_at_purchase ||= product.price if product
  end
end
