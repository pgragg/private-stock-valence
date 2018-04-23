namespace :makefiles do
  task offload_files_to_general_folder: :environment do
    `mkdir all_forms`
    companies.with_tickers.with_forms.each do |company|
      company.forms.where(name: '10-Q').each do |form|
        File.open('all_forms/' + form.filename, 'w') {|f| f.write form.filing_raw_text }
      end
    end
  end

  task symlink_market_data_based_on_performance: :environment do
    `mkdir pos_1_day`
    `mkdir neg_1_day`
    percent_changes = {}
    # Find all 10-Q forms belonging to companies which are described by StockPrice symbols
    stock_price_symbols = StockPrice.pluck(:symbol)
    companies = Company.where(ticker_symbol: stock_price_symbols)
    forms = Form.includes(:company).where(company_id: companies.pluck(:id), name: '10-Q')
    # Loop through all forms,
    forms[0..100].each do |form|
      previous_date = (form.filing_date - 1.day).to_s
      next_date = (form.filing_date + 1.day).to_s
      # finding the stock price open on the day before the news 
      stock_price_open = StockPrice.find_by(symbol: form.company.ticker_symbol, date: previous_date).open
      # and the stock price close on the day after the news.
      stock_price_close = StockPrice.find_by(symbol: form.company.ticker_symbol, date: next_date).close

      percent_changes[symbol] ||= {}
      percent_changes[symbol][form.quarter] = ((stock_price_close.to_f-stock_price_open.to_f)/stock_price_open.to_f)

      # If the close is lower, symlink to neg_1_day
      # If the close is higher, symlink to pos_1_day
    end
    byebug
  end

end
