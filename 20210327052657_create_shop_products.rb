class CreateShopProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :shop_products do |t|
      t.string 'price_list'
      t.string 'brand', null: false
      t.string 'code', null: false
      t.integer 'stock', default: 0, null: false
      t.decimal 'cost', precision: 12, scale: 2, null: false
      t.string 'name'

      t.timestamps
    end
    add_index :shop_products, [:price_list, :brand, :code], unique: true
  end
end
