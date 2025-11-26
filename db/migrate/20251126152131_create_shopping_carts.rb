class CreateShoppingCarts < ActiveRecord::Migration[8.0]
  def change
    create_table :shopping_carts do |t|
      t.timestamps
    end
  end
end
