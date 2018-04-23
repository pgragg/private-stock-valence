class Company < ApplicationRecord
  has_many :forms

  scope :with_tickers, -> { where.not(ticker_symbol: nil) }
  scope :with_forms, -> { where(id: Form.where(name: '10-K').or(Form.where(name: '10-Q')).pluck(:company_id) ) }
end
