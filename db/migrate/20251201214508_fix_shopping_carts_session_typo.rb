class FixShoppingCartsSessionTypo < ActiveRecord::Migration[8.0]
  def change
    rename_column :shopping_carts, :sesssion_id, :session_id
  end
end
