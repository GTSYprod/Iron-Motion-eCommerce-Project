class CreateOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_items do |t|
      t.references :order, foreign_key: true
      t.references :product, foreign_key: true
      t.integer :stock_quantity
      t.decimal :price_at_purchase, precision: 10, scale: 2
    end
  end
end
