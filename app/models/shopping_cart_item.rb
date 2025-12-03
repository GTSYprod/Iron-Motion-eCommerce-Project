class ShoppingCartItem < ApplicationRecord
  # Associations
  belongs_to :product
  belongs_to :shopping_cart

  # Validations (Requirement 4.2.1)
  validates :product, presence: true
  validates :shopping_cart, presence: true
  validates :item_quantity, presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :product_id, uniqueness: { scope: :shopping_cart_id }

  # Methods
  def subtotal
    product.price * item_quantity
  end
end
