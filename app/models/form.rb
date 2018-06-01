class Form < ApplicationRecord
  belongs_to :company
  
  def url
    "https://www.sec.gov/Archives/#{filing_url}"
  end

  def humanized_term
    return 'yearly' if name == '10-K' 
    return 'quarterly' if name == '10-Q'
    'no_term'
  end

  def filename
    "#{company.ticker_symbol}_#{filing_date}_#{humanized_term}.txt"
  end

  def self.valence(valence_type=:high_valence)
    filled = Form.where.not(filing_raw_text: nil).select(:id, :company_id, :filing_date)
    hv_forms = []
    filled.map do |form|
      if form.send(valence_type)
        hv_forms << form 
      end
    end
    hv_forms
  end

  def quantify_valence
    prices_open = company.stock_prices.order(:date).pluck(:date, :open).to_h
    prices_close = company.stock_prices.order(:date).pluck(:date, :close).to_h
    price_before_filing_date = prices_open[filing_date-1]
    price_on_filing_date = prices_open[filing_date]

    comparison_price = price_on_filing_date || price_before_filing_date

    price_after = prices_close[filing_date + 1]
    return 'na' unless price_after && comparison_price
    ((price_after-comparison_price)/comparison_price.to_f)
  end

  def high_valence
    prices = company.stock_prices.order(:date).pluck(:date, :open).to_h
    price_on_filing_date = prices[filing_date]
    price_after = prices[filing_date + 1]
    return false unless price_on_filing_date && price_after
    return true if (price_after-price_on_filing_date) > 0
  end

  def low_valence
    prices = company.stock_prices.order(:date).pluck(:date, :open).to_h
    price_on_filing_date = prices[filing_date]
    price_after = prices[filing_date + 1]
    return false unless price_on_filing_date && price_after
    return true if (price_after-price_on_filing_date) < 0
  end

end

# Stock price date symbol 
# Company ticker_symbol
# Form filing_date
