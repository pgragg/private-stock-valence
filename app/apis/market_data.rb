class MarketData

  API_KEY = 'QPL6YTN5VA6V7MP8'

  def initialize(symbol:, agent:, date:)
    @symbol = symbol
    @agent = agent
    @date = date
  end

  # def time_series_daily_adjusted
  #   @agent.get("https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=#{@symbol}" + \
  #   "&outputsize=full&apikey=#{API_KEY}")
  #   JSON.parse @agent.page.body
  # end

  # def date_performance
  #   begin 
  #     @agent.get("https://www.quandl.com/api/v3/datatables/WIKI/PRICES?date=#{@date}" + \
  #       "&ticker=#{@symbol}&api_key=Uyaf1-7qy5o9EJt8z_xc")
  #     raw = JSON.parse @agent.page.body
  #     symbol = raw['datatable']['data'][0][0]
  #     date = raw['datatable']['data'][0][1]
  #     open = raw['datatable']['data'][0][2]
  #     high = raw['datatable']['data'][0][3]
  #     low = raw['datatable']['data'][0][4]
  #     close = raw['datatable']['data'][0][5]
  #     {
  #       open: open,
  #       high: high,
  #       low: low,
  #       close: close,
  #       date: date,
  #       symbol: symbol
  #     }
  #   rescue
  #     {error: true}
  #   end
  # end

  # def time_series_intraday
  #   "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=#{@symbol}" + \
  #   "&interval=15min&outputsize=full&apikey=#{API_KEY}"
  # end

  ## USE THIS .
  def time_series_daily_adjusted
    begin 
      @agent.get "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=#{@symbol}" + \
      "&apikey=#{API_KEY}"
      response = JSON.parse @agent.page.body
      data = response[response.keys[1]][@date]
      {
          open: data["1. open"].to_f,
          high: data["2. high"].to_f,
          low: data["3. low"].to_f,
          close: data["4. close"].to_f,
          date: @date,
          symbol: @symbol
        }
    rescue 
      { error: true }
    end
  end

end 

# https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=MSFT&apikey=QPL6YTN5VA6V7MP8
# https://www.quandl.com/api/v3/datatables/WIKI/PRICES?date=1999-11-18&ticker=A&api_key=Uyaf1-7qy5o9EJt8z_xc
# https://www.marketwatch.com/tools/quotes/lookup.asp?lookup=1%20800%20FLOWERS%20COM%20INC
# Alpha Vantage: QPL6YTN5VA6V7MP8