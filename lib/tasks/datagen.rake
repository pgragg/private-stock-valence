namespace :datagen do
  desc "Creates companies and forms from indexed data"

  task create_indices_of_companies: :environment do 
    Array(1993..2018).each do |year|
      Array(1..4).each do |quarter|
        `curl https://www.sec.gov/Archives/edgar/full-index/#{year}/QTR#{quarter}/company.idx > indices/#{year}_#{quarter}.idx`
      end
    end
  end

  task create_companies_and_forms: :environment do

    Dir.glob('indices/*.idx').sort.each do |filename| 
      file = File.open(filename, 'r').read
      year = filename.split('/').last.split('_').first.to_i
      quarter = filename.split('_').last.split('.').first.to_i
      next if year < 2017
      if year == 2017
        next if quarter <= 2
      end
      
      company_rows = file.split('-'*141).last.split("\n") rescue next 
      individual_company_information = []
      company_rows.map do |company_row| 
        individual_company_information << company_row.split('  ').keep_if {|section| section.length > 2} 
      end
      individual_company_information.each do |company_info| 
        next unless company_info.length == 5
        company_name    = company_info[0].strip
        form_type       = company_info[1].strip
        cik             = company_info[2].strip
        filing_date     = company_info[3].strip
        filing_url      = company_info[4].strip

        company = Company.find_or_create_by(cik: cik, name: company_name)
        form = Form.find_or_create_by({
          company_id: company.id,
          name: form_type, 
          filing_date: filing_date, 
          filing_url: filing_url,
          quarter: quarter,
          year: year
          })
      end
    end 
  end

  task populate_form_filing_raw_text: :environment do 
    require 'mechanize'
    agent = Mechanize.new {|agent| agent.user_agent_alias = 'Mac Safari'}

    ## Warning: this will generate over 400GB of data (5mb per form).
    # Form.where(name: '10-K', filing_raw_text: nil).each do |form| 
    #   text = agent.get(form.url).body
    #   form.update_attributes(filing_raw_text: text) rescue nil
    # end
    forms_to_check = Form.where(name: '10-Q', filing_raw_text: nil).count
    Form.where(name: '10-Q', filing_raw_text: nil).each_with_index do |form, index|
      p "#{index + 1}/#{forms_to_check}"
      form.update_attributes(filing_raw_text: agent.get(form.url).body) rescue nil
    end

  end

  # This task needs to be run many times since it sometimes fails. 
  # so write a ruby script that goes, 1000.times { `make symbols` }
  # :D 
  task populate_company_symbols: :environment do
    require 'mechanize'
    agent = Mechanize.new {|agent| agent.user_agent_alias = 'Mac Safari'}
    companies_needing_tickers = Company.with_forms.where(ticker_symbol: nil).where("created_at > '2018-03-11'")
    company_names = companies_needing_tickers.pluck(:name)
    companies_needing_tickers.each do |company|
      sleep(1)
      begin 
        company_name = company.name
        p company_name
        uri = "https://www.marketwatch.com/tools/quotes/lookup.asp?lookup=#{URI.encode(company_name)}"
        page = agent.get(uri)
        ticker_symbol = page.css('td.bottomborder')[0].text
        p ticker_symbol
        ticker_company_name = page.css('td.bottomborder')[1].text
        p ticker_company_name
        distance = Levenshtein.distance(ticker_company_name.upcase, company_name.upcase)
        p distance
        if distance < 12
          company.update_attributes(ticker_symbol: ticker_symbol)
        end
      rescue

      end
    end

  end

  task record_historical_market_performance: :environment do
    require 'mechanize'
    agent = Mechanize.new {|agent| agent.user_agent_alias = 'Mac Safari'}
    attempts = 0
    successes = 0
    Company.with_tickers.with_forms.each do |company|
      dates = company.forms.where(name: '10-Q').pluck(:filing_date)
      dates = dates.map {|d| [d, (d-1.day).to_date, (d+1.day).to_date].map(&:to_s) }.flatten.uniq
      symbol = company.ticker_symbol
      dates.each do |date|
        attempts += 1
        stock_price = MarketData.new(symbol: symbol, date: date, agent: agent).time_series_daily_adjusted
        next if stock_price[:error] == true
        successes += 1
        StockPrice.find_or_create_by(stock_price)
      end
      p "Attempts: #{attempts}"
      p "Successes: #{successes}"
    end
  end

end
