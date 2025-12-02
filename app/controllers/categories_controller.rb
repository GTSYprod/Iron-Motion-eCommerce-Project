class CategoriesController < ApplicationController
  # Requirement 2.2 - Navigate products by category
  def show
    @category = Category.find(params[:id])
    @products = @category.products
                        .includes(:category, images_attachments: :blob)
                        .page(params[:page]).per(12)
    @categories = Category.all
  end
end
