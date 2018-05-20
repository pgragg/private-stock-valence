namespace :datagen do
  desc "Creates companies and forms from indexed data"

  task bucket_form_text_by_valence: :environment do 
    # Form.valence(:low_valence).each do |form|
    #   filename = "#{form.company.ticker_symbol}#{form.filing_date.to_s}"
    #   filepath = Rails.root.join('texts_by_valence', 'low', filename)
    #   File.open(filepath, 'w+') do |file|
    #     file.write Form.find(form.id).filing_raw_text
    #   end
    # end
    Form.valence(:high_valence).each do |form|
      filename = "#{form.company.ticker_symbol}#{form.filing_date.to_s}"
      filepath = Rails.root.join('texts_by_valence', 'high', filename)
      File.open(filepath, 'w+') do |file|
        file.write Form.find(form.id).filing_raw_text
      end
    end
  end

  task everything: :environment do
    tasks = [
      "datagen:create_companies_from_table", # seconds 
      "datagen:create_indices_of_companies", # seconds 
      "datagen:create_companies_and_forms", # seconds 
      "datagen:populate_company_symbols", # 2 hours 
      "datagen:record_historical_market_performance", # 
      "datagen:populate_form_filing_raw_text"
    ]
    tasks.each do |task|
      p "Invoking: #{task}"
      Rake::Task[task].invoke
    end
  end 

  task create_companies_from_table: :environment do
    f = File.open('table.txt').read
    i = 6

    cells = f.split('<td>')

    output = {}

    while i < cells.count 
      string = cells[i]
      company_name = string.match(/>.*<\/a>/).to_s.split('>')[-1].split('<')[0].gsub('&amp;', '&')
      ticker_symbol = string.split('?q=')[1].split('>').first.split('"')[0]
      next unless company_name && ticker_symbol
      output[company_name] = ticker_symbol
      i += 4
    end

    output.each do |name, ticker_symbol|
      Company.find_or_create_by(name: name, ticker_symbol: ticker_symbol)
    end
  end
  task create_indices_of_companies: :environment do 
    # 1993
    Array(2017..2018).each do |year|
      Array(1..4).each do |quarter|
        `curl https://www.sec.gov/Archives/edgar/full-index/#{year}/QTR#{quarter}/company.idx > indices/#{year}_#{quarter}.idx`
      end
    end
  end

  task create_companies_and_forms: :environment do
    total = Dir.glob('indices/*.idx').count
    Dir.glob('indices/*.idx').sort.each_with_index do |filename, i| 
      p "#{i}/#{total}" if i % 1000 == 0
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
        next unless form_type == '8-K'

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

  # This task needs to be run many times since it sometimes fails. 
  # so write a ruby script that goes, 1000.times { `make symbols` }
  # :D 
  task populate_company_symbols: :environment do
    require 'mechanize'
    agent = Mechanize.new {|agent| agent.user_agent_alias = 'Mac Safari'}
    
    companies_needing_tickers = Company.with_forms.where(ticker_symbol: nil)
    company_names = companies_needing_tickers.pluck(:name)
    companies_needing_tickers.reverse.each do |company|
      sleep(1)
      begin 
        company_name = company.name.downcase
        company_name.gsub!('/de/', '')
        company_name.gsub!(' inc', '') if company_name[-3..-1] == 'inc'
        company_name.gsub!(' corp', '') if company_name[-4..-1] == 'corp'
        company_name.gsub!(' inc ', '') 
        company_name.gsub!('inc.', '')
        company_name.gsub!(', inc.', '')
        uri = "https://www.marketwatch.com/tools/quotes/lookup.asp?lookup=#{URI.encode(company_name)}"
        page = agent.get(uri)
        ticker_symbols = []
        ticker_company_names = []
        page.css('td.bottomborder').to_a.each_with_index do |item, i|
          text = item.text
          ticker_symbols << text if (i % 3 == 0)
          next if i == 0
          ticker_company_names << text if (i%3 == 1)
        end
        companies = []
        index_of_closest_name = 0
        lowest_distance = 100
        ticker_company_names.each_with_index do |ticker_company_name, i|
          distance = Levenshtein.distance(ticker_company_name.downcase, company.name.downcase)
          if distance < lowest_distance
            index_of_closest_name = i
            lowest_distance = distance
          end
        end

        p company_name
        p ticker_company_names[index_of_closest_name]
        p ticker_symbols[index_of_closest_name]
        p lowest_distance

        if lowest_distance < 3
          company.update_attributes(ticker_symbol: ticker_symbols[index_of_closest_name])
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
      dates = company.forms.where(name: '8-K').pluck(:filing_date)
      dates = dates.map {|d| [d, (d-1.day).to_date, (d+1.day).to_date].map(&:to_s) }.flatten.uniq
      symbol = company.ticker_symbol
      dates.each do |date|
        attempts += 1
        stock_price = MarketData.new(symbol: symbol, date: date, agent: agent).date_performance
        next if stock_price[:error] == true
        successes += 1
        StockPrice.find_or_create_by(stock_price)
      end
      p "Attempts: #{attempts}"
      p "Successes: #{successes}"
    end
  end

  task populate_form_filing_raw_text: :environment do 
    require 'mechanize'
    agent = Mechanize.new {|agent| agent.user_agent_alias = 'Mac Safari'}
    
    ## Warning: this will generate 5mb per form. 
    Form.where(
      {
        name: '10-K', 
        filing_raw_text: nil,
        company_id: Company.where(ticker_symbol: StockPrice.all.pluck(:symbol).uniq).pluck(:id)
      }).each do |form| 
      text = agent.get(form.url).body
      form.update_attributes(filing_raw_text: text) rescue nil
    end
    # forms_to_check = Form.where(name: '10-Q', filing_raw_text: nil).count
    # Form.where(name: '10-Q', filing_raw_text: nil).each_with_index do |form, index|
    #   p "#{index + 1}/#{forms_to_check}"
    #   form.update_attributes(filing_raw_text: agent.get(form.url).body) rescue nil
    # end

  end

end
