class ShoppingCart < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  has_many :shopping_cart_items, dependent: :destroy
  has_many :products, through: :shopping_cart_items

  # Validations (Requirement 4.2.1)
  validates :session_id, uniqueness: true, allow_blank: true
  validate :has_user_or_session

  # Methods (Requirement 3.1.1 - 3.1.3)
  def add_item(product, quantity = 1)
    item = shopping_cart_items.find_or_initialize_by(product: product)
    item.item_quantity = (item.item_quantity || 0) + quantity
    item.save
  end

  def update_item_quantity(product, quantity)
    item = shopping_cart_items.find_by(product: product)
    return unless item

    if quantity.to_i > 0
      item.update(item_quantity: quantity)
    else
      item.destroy
    end
  end

  def remove_item(product)
    shopping_cart_items.find_by(product: product)&.destroy
  end

  def total
    shopping_cart_items.includes(:product).sum do |item|
      item.product.price * item.item_quantity
    end
  end

  def item_count
    shopping_cart_items.sum(:item_quantity)
  end

  def empty?
    shopping_cart_items.empty?
  end

  def clear
    shopping_cart_items.destroy_all
  end

  private

  def has_user_or_session
    if user_id.blank? && session_id.blank?
      errors.add(:base, "Must have either a user or session")
    end
  end
end
