class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.references :category, foreign_key: true
      t.string :image_url
      t.string :stock_status
      t.text :specification
      t.timestamps
    end
  end
end
