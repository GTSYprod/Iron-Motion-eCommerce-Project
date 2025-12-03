class ProductsController < ApplicationController
  # Requirement 2.1: Navigate products via front page
  # Requirement 2.3: View product details on own page
  # Requirement 2.4: Filter by On Sale, New, Recently Updated
  # Requirement 2.6: Keyword search

  def index
    @products = Product.includes(:category, images_attachments: :blob)

    # Filter by category (Requirement 2.2)
    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end

    # Filter scopes (Requirement 2.4)
    @products = @products.on_sale if params[:on_sale] == "true"
    @products = @products.new_arrivals if params[:new_arrivals] == "true"
    @products = @products.recently_updated if params[:recently_updated] == "true"

    # Pagination (Requirement 2.5)
    @products = @products.page(params[:page]).per(12)

    # Categories for filter
    @categories = Category.all
  end

  def show
    @product = Product.includes(:category, images_attachments: :blob).find(params[:id])
  end

  def search
    # Requirement 2.6 - keyword search
    if params[:query].present?
      @products = Product.search(params[:query])
                        .includes(:category, images_attachments: :blob)
                        .page(params[:page]).per(12)
    else
      @products = Product.none.page(params[:page])
    end

    @categories = Category.all
    render :index
  end
end
