class UpdateProductsForActiveStorage < ActiveRecord::Migration[8.0]
  def change
    # Remove image_url column since we're using Active Storage
    remove_column :products, :image_url, :string

    # Add fields for filtering requirements (2.4)
    add_column :products, :on_sale, :boolean, default: false
    add_column :products, :is_new, :boolean, default: false

    # Add stock quantity for inventory management
    add_column :products, :stock_quantity, :integer, default: 0
  end
end
