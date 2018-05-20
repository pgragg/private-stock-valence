companies:
	docker-compose run app bundle exec rake datagen:create_companies_and_forms
texts: 
	docker-compose run app bundle exec rake datagen:populate_form_filing_raw_text
symbols: 
	docker-compose run app bundle exec rake datagen:populate_company_symbols
performance: 
	docker-compose run app bundle exec rake datagen:record_historical_market_performance
make_files:
	docker-compose run app bundle exec rake makefiles:offload_files_to_general_folder
symlink: 
	docker-compose run app bundle exec rake makefiles:symlink_market_data_based_on_performance
console: 
	docker-compose run app bundle exec rails c
bash: 
	docker-compose run app bash
bundle: 
	docker-compose run app bundle
schemaload: 
	docker-compose run app bundle exec rake db:create db:schema:load