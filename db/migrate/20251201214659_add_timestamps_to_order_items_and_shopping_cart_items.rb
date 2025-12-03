class AddTimestampsToOrderItemsAndShoppingCartItems < ActiveRecord::Migration[8.0]
  def change
    add_timestamps :order_items, default: -> { 'CURRENT_TIMESTAMP' }
    add_timestamps :shopping_cart_items, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
