class CreateStockPrices < ActiveRecord::Migration[5.1]
  def change
    create_table :stock_prices do |t|
      t.float :open
      t.float :high
      t.float :low
      t.float :close
      t.date :date
      t.string :symbol

      t.timestamps
    end
    add_index :stock_prices, :open
    add_index :stock_prices, :high
    add_index :stock_prices, :low
    add_index :stock_prices, :close
    add_index :stock_prices, :date
    add_index :stock_prices, :symbol
  end
end
