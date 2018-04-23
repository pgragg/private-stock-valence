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

end
