class ShoppingCartsController < ApplicationController
  before_action :set_cart

  # Requirement 3.1.1, 3.1.2 - Shopping cart functionality
  def show
    @cart_items = @cart.shopping_cart_items.includes(product: { images_attachments: :blob })
  end

  # Requirement 3.1.1 - Add products to cart
  def add_item
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i

    if quantity > 0
      @cart.add_item(product, quantity)
      redirect_to shopping_cart_path, notice: "#{product.name} added to cart!"
    else
      redirect_to product_path(product), alert: "Invalid quantity."
    end
  end

  # Requirement 3.1.2 - Edit cart quantities
  def update_item
    cart_item = @cart.shopping_cart_items.find(params[:id])

    if params[:item_quantity].to_i > 0
      cart_item.update(item_quantity: params[:item_quantity])
      redirect_to shopping_cart_path, notice: "Cart updated."
    else
      cart_item.destroy
      redirect_to shopping_cart_path, notice: "Item removed from cart."
    end
  end

  # Requirement 3.1.2 - Remove items from cart
  def remove_item
    cart_item = @cart.shopping_cart_items.find(params[:id])
    product_name = cart_item.product.name
    cart_item.destroy
    redirect_to shopping_cart_path, notice: "#{product_name} removed from cart."
  end

  # Clear entire cart
  def clear
    @cart.clear
    redirect_to shopping_cart_path, notice: "Cart cleared."
  end

  private

  def set_cart
    if user_signed_in?
      # For logged-in users, use their shopping cart
      @cart = current_user.shopping_cart || current_user.create_shopping_cart
    else
      # For guest users, use session-based cart
      session[:cart_id] ||= SecureRandom.uuid
      @cart = ShoppingCart.find_or_create_by(session_id: session[:cart_id])
    end
  end
end
