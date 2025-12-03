class StaticPage < ApplicationRecord
  # ActionText for rich content editing
  has_rich_text :content

  # Validations (Requirement 4.2.1)
  validates :title, presence: true, length: { minimum: 2, maximum: 200 }
  validates :slug, presence: true, uniqueness: true,
            format: { with: /\A[a-z0-9-]+\z/,
                     message: "only allows lowercase letters, numbers, and hyphens" }
  validates :content, presence: true

  # Callbacks
  before_validation :generate_slug, if: -> { title_changed? || slug.blank? }

  # Scopes
  scope :published, -> { where(published: true) }
  scope :drafts, -> { where(published: false) }

  private

  def generate_slug
    self.slug = title.parameterize if title.present?
  end

  # Ransack configuration for ActiveAdmin search
  def self.ransackable_associations(auth_object = nil)
    []
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "published", "slug", "title", "updated_at"]
  end
end
