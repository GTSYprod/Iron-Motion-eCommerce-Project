class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true
      t.references :address, foreign_key: true
      t.decimal :order_total
      t.string :order_status
      t.timestamps
    end
  end
end
