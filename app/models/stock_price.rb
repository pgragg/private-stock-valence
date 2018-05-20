class StockPrice < ApplicationRecord

  def company
    Company.find_by(ticker_symbol: symbol)
  end
end
