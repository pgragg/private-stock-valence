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


 # t.string "name"
 #    t.string "cik"
 #    t.datetime "created_at", null: false
 #    t.datetime "updated_at", null: false
 #    t.string "ticker_symbol"
 #    t.index ["cik"], name: "index_companies_on_cik"
 #    t.index ["name"], name: "index_companies_on_name"
 #    t.index ["ticker_symbol"], name: "index_companies_on_ticker_symbol"