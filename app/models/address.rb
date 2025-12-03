class Address < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :orders, dependent: :restrict_with_error

  # Validations (Requirement 4.2.1 and 3.1.5)
  validates :user, presence: true
  validates :street_address, presence: true, length: { minimum: 5, maximum: 200 }
  validates :city, presence: true, length: { minimum: 2, maximum: 100 }
  validates :province, presence: true, length: { minimum: 2, maximum: 100 }
  validates :postal_code, presence: true,
            format: { with: /\A[A-Z]\d[A-Z] ?\d[A-Z]\d\z/i,
                     message: "must be a valid Canadian postal code" }

  # Callbacks
  before_save :normalize_postal_code
  after_save :ensure_only_one_default, if: :is_default?

  # Scopes
  scope :default_address, -> { where(is_default: true) }

  # Methods
  def full_address
    "#{street_address}, #{city}, #{province} #{postal_code}"
  end

  private

  def normalize_postal_code
    self.postal_code = postal_code.upcase.gsub(/\s+/, '') if postal_code
  end

  def ensure_only_one_default
    Address.where(user_id: user_id)
           .where.not(id: id)
           .update_all(is_default: false)
  end
end
