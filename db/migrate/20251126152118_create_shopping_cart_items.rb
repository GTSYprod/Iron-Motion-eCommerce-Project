class CreateShoppingCartItems < ActiveRecord::Migration[8.0]
  def change
    create_table :shopping_cart_items do |t|
      t.timestamps
    end
  end
end
