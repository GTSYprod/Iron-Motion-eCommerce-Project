class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name
      t.text :description
      t.integer :parent_category_id, index: true
      t.timestamps
    end
  end
end
