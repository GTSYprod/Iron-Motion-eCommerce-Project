class User < ApplicationRecord
  has_secure_password

  has_many :orders
  has_many :addresses
  has_one :shopping_cart
end
