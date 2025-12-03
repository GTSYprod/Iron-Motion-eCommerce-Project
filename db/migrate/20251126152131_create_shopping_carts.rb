class CreateShoppingCarts < ActiveRecord::Migration[8.0]
  def change
    create_table :shopping_carts do |t|
      t.references :user, foreign_key: true
      t.string :sesssion_id
      t.timestamps
    end
  end
end
