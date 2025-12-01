class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :orders, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_one :shopping_cart, dependent: :destroy

  # Validations (Requirement 4.2.1)
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }

  # Callbacks
  after_create :create_shopping_cart

  # Methods
  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def create_shopping_cart
    ShoppingCart.create(user: self) unless shopping_cart.present?
  end
end
