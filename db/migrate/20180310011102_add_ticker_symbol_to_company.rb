class AddTickerSymbolToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :ticker_symbol, :string
    add_index :companies, :ticker_symbol
  end
end
