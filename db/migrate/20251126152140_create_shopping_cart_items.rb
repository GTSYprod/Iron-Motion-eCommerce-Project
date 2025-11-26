class CreateShoppingCartItems < ActiveRecord::Migration[8.0]
  def change
    create_table :shopping_cart_items do |t|
      t.references :shopping_cart, foreign_key: true
      t.references :product, foreign_key: true
      t.integer :item_quantity
    end
  end
end
