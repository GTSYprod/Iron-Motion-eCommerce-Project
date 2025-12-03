class RenameOrderItemsStockQuantity < ActiveRecord::Migration[8.0]
  def change
    # Rename stock_quantity to quantity (more semantic for order items)
    rename_column :order_items, :stock_quantity, :quantity
  end
end
