module Checkout
  class CheckoutController < ApplicationController
    before_action :authenticate_user!
    before_action :set_cart
    before_action :ensure_cart_not_empty

    # Requirement 3.1.3 - Complete checkout process
    def new
      @addresses = current_user.addresses
      @selected_address = current_user.addresses.default_address.first || current_user.addresses.first
    end

    def create
      address = current_user.addresses.find(params[:address_id])

      # Create order items from cart items
      order_items_attributes = @cart.shopping_cart_items.map do |cart_item|
        {
          product_id: cart_item.product_id,
          quantity: cart_item.item_quantity,
          price_at_purchase: cart_item.product.price
        }
      end

      # Create the order
      @order = current_user.orders.build(
        address: address,
        order_status: 'pending',
        order_items_attributes: order_items_attributes
      )

      if @order.save
        # Clear the cart after successful order
        @cart.clear
        redirect_to order_path(@order), notice: "Order placed successfully!"
      else
        @addresses = current_user.addresses
        @selected_address = address
        flash.now[:alert] = "There was an error processing your order."
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_cart
      @cart = current_user.shopping_cart || current_user.create_shopping_cart
    end

    def ensure_cart_not_empty
      if @cart.empty?
        redirect_to shopping_cart_path, alert: "Your cart is empty."
      end
    end
  end
end
