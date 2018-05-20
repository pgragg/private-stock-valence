class Company < ApplicationRecord
  has_many :forms

  scope :with_tickers, -> { where.not(ticker_symbol: nil) }

  def self.with_forms
    self.where(id: Form.where(name: '10-K').pluck(:company_id) )
  end

  def self.without_forms
    self.where.not(id: Form.where(name: '10-K').pluck(:company_id) )
  end

  def stock_prices
    StockPrice.where(symbol: self.ticker_symbol)
  end
end
