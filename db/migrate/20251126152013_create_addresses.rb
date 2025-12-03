class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.references :user, foreign_key: true
      t.string :street_address
      t.string :city
      t.string :province
      t.string :postal_code
      t.boolean :is_default
      t.timestamps
    end
  end
end
