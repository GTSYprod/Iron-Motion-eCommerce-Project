class Product < ApplicationRecord
  belongs_to :category

  has_many :order_items
  has_many :shopping_cart_items

  has_many :orders, through: :order_items
  has_many :shopping_carts, through: :shopping_cart_items
end
